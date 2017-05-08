*430 PM 5/4*

# Review of Problem Statement
## The Web Project - TinyURL Overview
Produce a "TinyURL" service:
  - like bitly or Google url shortener, when I enter a URL I get a "short" URL e.g., https://wizeservices.com/careers ⇒ https://localhost:3000/corto
  - when I browse to a "short" URL, it redirects to the original URL e.g., https://localhost:3000/corto ⇒ https://wizeservices.com/careers
  - when I visit some specific URL, I see a list of the short and long URL pairs in the system

## Constraints
- include at least some "minimal" front-end user interface for creating and listing the URLs -- i.e., it cannot be an API-only implementation *Need a web view to enter, recieve and list the urls*
- be able to handle at least 1,000,000 unique "short" URLs *Response: encoding will need to be c characters from a set of size k where k^c > 1,000,000*
- be in some kind of Source Code Control System you can share with us (e.g., a repo on Github, Jira, etc.;, a copy of your local repo; access to an SVN server, etc.)
*Using Git*
- Your implementation may not call any external URL-shortening service. *:)*
- Beyond that, feel free to use any language, tools, frameworks, online resources, etc. to implement your project. *using ruby and rails for productivity*

## Presentation
We will ask you to present your design and implementation.

During your presentation, please be prepared to...
- demonstrate your project
- discuss your choices (e.g., language, tools, framework, design, etc.) and trade-offs
- discuss how it should be able to handle concurrent requests

It’s very important that you include a journal where you explain how much time did you spend planning and coding to solve the problem. Be prepared to present that information to the team.

## Future
- we will present new or changed requirements
- you will lead a discussion of how to meet them
- you will have some time to make the changes
- you will demonstrate and present your revised project.

# Scope
What are we building?
- A web application with a UI for entering a URL and displaying a shortened link.
- A view for inspecting the mapping of short urls to long urls.
- Mapping a short link to a long link so when the short link is visited you are redirected to the long
- Auto generating up to 1 million or more unique short links.

Do we need user auth? For simplicity, I am assuming we do not need user accounts at this point.

Can people modify or delete links? Since we don't have users, I'm going to assume that links are immutable at this point.

Do I need to add pagination for the view to inspect the mapping of short urls to long urls? In a real system we absolutely would need this. I'm assuming for our purposes we won't actually generate millions url pairs.

Do we expire links? We could have an expiration date or if a link hasn't been visited in a given time window we could expire them. I think that the problem with expiring links is we are guessing at the use cases of the links. What if someone creates a shortened link to put on a flyer and then waits several months before posting them or a user picks up a flyer sever months later and tries to go to the link but can't. Let's limit the amount of assumptions we make about how these links will be used. Disk space is cheap.

Do people shorten their own links or are they auto-generated? This seems like something people might want but, for now, let's assume this is a later feature to add.

Do we want extras like analytics? ie. how many tiems the link is accessed. This isn't a core feature but would add a lot of value in the future. Let's add it to the backlog.

# Design Goals and Bottlenecks
What are we optimizing for? If we are going to store links forever it won't be space. Instead let's make the redirect for the user as fast as possible and as easy to remember (short) as possible.

How can we make lookups fast? We will want want to index the short links in our database for optimal lookup. Although, with only a million rows (assuming relational DB) the bottleneck might not even be a linear scan but time on the wire for queries from our application to our DB. We will also want to make sure to put our DB in the same data center as our servers if possible. If in the future we allow users to create their own links, this will make the check against the database fast as well.

How much space do we need? If each pair of URLs is around 200 bytes and we have a million that is something like 200 mb, a fairly trivial amount of data for modern systems. In the future if we want to store billions or trillions of links then we may need to consider horizontal DB scaling solutions but for now (and for an order of magnitude) it is a non-issue.

We also want to consider QPS requirements. If someone post a link in the New York Times it might get a lot of hits. For ballpark QPS let's consider that 1 hundred thousand people might see a link in the media at any given minute in time and at most 10% of them will visit the link. 100,000 * 0.1 / 60 = 166 QPS. This can be handled by a single server easily. If we need to scale up and handle an order of magnitude more requests then we might add a few more boxes with a load balancer in front. For most production systems this is pushed down to an infrastructure as a service platform (AWS, Google AppEngine etc.)

# Data Model
TinyURLs table
--------
str slug
str destination
date created_at

We don't really need an id, since slugs have to be guaranteed to be unique. We will want a primary key constraint on slug. It should both validate uniqueness and be indexed for speedy lookups.

# Actions
GET shrt.com/slugs/
  - will show slugs and destination urls
GET shrt.com/slugs/new
  - input text box to paste in link
  - button to click submit
  - return flash or text on page with short link
GET shrt.com/r/<slug>
POST shrt.com/slugs(:slug, :destination)
{
  "slug":"0000",
  "destination":"example.com"
}

# Core Feature Algo - URL Generation
The feature is relatively simple. We are essentially creating a giant look up table that does a few things:
1) Generates a unique string that is as short as possible on request
2) Associates that string with a redirect url
3) Is persisted for later access

Let's consider being able to have c characters that have 1 million or more permutations. This depends on two things: the size of the char set and the length of chars allowed in the string. The relationship is exponential: k^c where k is the characters in the set and c is length of the string.

If we only used alphanumeric values we'd have: 26*2 (since capitals are significant in URLs according to the relevant RFC) + 10 (digits 0-9) is 62. In other words, we are using base 62.

For simplicity let's exclude all other characters so we don't have to escape reserved url characters such as '?'. This will give us 62^1 for c==1 and 8.4 * 10 ^17 for c == 10. However we want as few characters as possible to keep our links short. What is the minimal super set of 1 million?

Solving for k...
62^k > 1,000,000
k*log(62) > log(1,000,000)
k*1.8 > 6
k >= 6/1.8
k >= 3.33 therefore k = 4 (can't have .33 chars)

With k == 4 we can have nearly 15 million characters with only 4 characters.

# Concurrent Requests
With a single server and database instance this is simple. The concurrent requests will always be queued by Rails. Postgres has a way of keeping track and knowing what the last primary key was. We will simply use the base id and change it's base to 62 to generate the slug. Whenever that parameter is given we navigate to that page.

# Generating our Short URL
We could randomly roll a slug and check against the db but as the db fills up we will have more and more collisions and the number of rolls will grow drastically.

We'd rather always be sure we are getting a unique slug. I'm assuming that we do not need to account for use specified slugs (random slots being taken up) and don't need to handle collisions we can increment whatever our last base-62 slug was.

Ex.
0000
0001
0002
0003
...
aB01
aB02
...
ZZZZ
*Stopped 5/4 545 PM*

*Started at 10 AM Saturday*
base-62 = '0123456789abcdefghijklmnopqrstubwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

For example if we are mapping 125 base-10 to base-62 then we need to find the where a*62^0 + b*62^1 + c*62^2 is 125.

The largest number that can fit inside of 125 is 62. 125/62 is 2 remainder 1 so we have 21 as our base-62 number.

For 8453 we have 8453/3844 which is 2 remainder 765. 765 / 62 = 12 (c) remainder is 21. 21 in our base 62 would be the 10th char in the alphabet which would be l. So, our our conversion is: '2bk'

[slicing html pages...]
*Stopped @ 11 AM 5/6*

*Started @ 5PM 5/6*
[adding creation of a new link with core models and driving out with TDD]

Still need to add url validation in the controller and add tests for the controller. And of course we need to add the redirect feature and the view shortlinks feature.
*Stopped @ 8 PM 5/6*

*Start @ 730 PM 5/7*
Need to look up how to get the root application url from the controller
