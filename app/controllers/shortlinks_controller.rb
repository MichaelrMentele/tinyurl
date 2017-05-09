class ShortlinksController < ApplicationController
  helper ApplicationHelper

  def index
    @shortlinks = Shortlink.all
    @decorator = ShortlinkDecorator.new(request.base_url)
    if @shortlinks.count == 0
      flash[:info] = "There are currently no shortlinks to display."
    end
  end

  def new
    @shortlink = Shortlink.new
  end

  def create
    created_shortlink = Shortlink.new(shortlink_params)
    if created_shortlink.save
      link = ShortlinkDecorator.new(request.base_url)
      flash[:success] = "Shortlink created: #{link.prepend_base_url(created_shortlink)}"
    else
      flash[:error] = "Is that a valid URL?"
    end

    redirect_to new_shortlink_path
  end

  def redirect
    link = Shortlink.find_by(slug: redirect_slug)
    if link
      redirect_to link.destination
    else
      flash[:error] = "Which shortlink did you mean to go to?"
      redirect_to shortlinks_path
    end
  end

  private

  def shortlink_params
    params.require(:shortlink).permit(:destination)
  end

  def redirect_slug
    params.permit(:slug)
    params["slug"]
  end
end
