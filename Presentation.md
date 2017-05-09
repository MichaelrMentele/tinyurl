# Overview

Time Spent:
- Total 11 Hours

Breakdown:
- 35% Understanding the problem
  - scope
  - goals
  - core algorithm
- 20% System Design
  - data model
  - actions
  - UI Mocking
- 25% Building
  - TDD by feature
- 15% Presentation

# Details
## Step 1: Understanding the Problem
### Scope
- Associate 1 million unique shortlinks w/ destination
- no auth
- no tracking metrics
- no link modifications
- no expiring links
- no pagination of shortlinks index
- auto-generated slugs
- no user generated slugs
### Design Goals
- space req.
  - 200 bytes * 1 million = 200 mb
- QPS and scaling path
  - 100 QPS  -> single server
  - 2000 QPS -> 3+ servers with load balancer
  - same data center
  - index slug column
  - Multiple application servers
  - Links sharing is read heavy -> DB Master/Slave replication
- graceful handling of concurrent requests / slug collisions
  - Postgres MVCC
  - guarantee each slug is unique by using PK
- compact links
  - convert to base 62 for compactness

## Step 2: System Design
### Data Model
TinyURLs table
--------
str slug
str destination
date created_at

We don't really need an id, since slugs have to be guaranteed to be unique. We will want a primary key constraint on slug. It should both validate uniqueness and be indexed for speedy lookups.

### Actions
- redirection under /r/:slug, could have also used subdomains and removed
  the extra /r. I didn't for simplicity. Instead of .com could have used 2
  characters. http://tny.co/:slug vs. http://tinyurl.com/r/:slug

### Core Algorithm
- random vs. sequential auto generated
- guaranteed unique (DB id)
- solve c^(k) > 1 million where c is num chars in set and k is length of string
    Solving for k...
    62^k > 1,000,000
    k*log(62) > log(1,000,000)
    k*1.8 > 6
    k >= 6/1.8
    k >= 3.33 therefore k = 4 (can't have .33 chars)
- selection of char set:
  - ease of typing
  - capitals are unique in URLs (RFC: https://tools.ietf.org/html/rfc3986)
- base_62 length of 4 is over 15 million

## Step 3: Tool Selection
  - Ruby on Rails
  - productive
  - very little server computation

## Step 4: Interface
- navigation
- flash messages
- html_slices controller
  - create new tinyurl
  - view tinyurl pairs
- tools: html/css, bootstrap

## Step 5: TDD by Feature
  - process: feature spec -> controller spec -> model spec
  - tools: capybara, erb templates, and rspec

PG                ->    ORM (ActiveRecord)       ->    Controller
Shortlink Table         Shortlink Model                ShortlinksController
- id PK                 - validates url                - decorator
- slug (indexed)        - callback: id to base_62      - #redirect
- destination                                          - #new, #index, #create
- timestamps

## Step 5: Future
- less predictable ids (shortlinks paths)
  - base_10 -> 62 -> hashing
  - /r/:slug
  - domain/r/:slug
  - domain/shortlinks
  - app.domain/shortlinks
  - domain/:hashedslug
- User entered slugs
  - suggesting, similar paths
  - we can no longer just convert the id to base_62
  - I think we can eagerly insert, if it bounces back, then try the next one and
    so forth.
  - path:            
  -
  - id 0,1,2,3,4
  - |x|x|x|x| | | | |x|x|x|x|
            ^          ^ ^ ^
  - |x| |x| | | | | |x|x|x| |
      

  links
  -----
  path <- adslkfj
  path <- abc

  random roll 1 - ZZZZ



- Add analytics
  - number of links visited, increment everytime a url is visited
  - where they came from, user agent, request header information?
  - feature: page with most
    - most frequently visited domains (top 10)
- detecting abuse
  - malicious bots and greedy users
  - look for:
    - repeat links
    - repeat requests from same IP
    - throttling of links from a given IP
- Handle 1 trillion unique integers, can PG still handle this? Will need to consider
  space in this situation.
  - 200 gb for 1 billion
  - 200 tb for 1 trillion https://www.pgcon.org/2011/schedule/attachments/193_pgCon%202011%20-%20Managing%20Terabytes.pdf
- Handle 2000 QPS? 5000 QPS?
  - scale horizontally
  - 9/10 query are reads
  - more replicant DBs for read as needed
  - sharding and reserving a range of slugs per machine?
- Expiring shortlinks
  - query on creation if any previous slugs have a nil destination, if yes, then update its destination and return
    its slug.
  - Will want to index destination for quick identification of nil
