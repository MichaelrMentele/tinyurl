class ShortlinksController < ApplicationController
  def new
    @shortlink = Shortlink.new
  end

  def create
    created_shortlink = Shortlink.new(shortlink_params)
    if created_shortlink.save
      link = request.base_url + "/r/#{created_shortlink.slug}"
      flash[:success] = "Shortlink created: #{link}"
    else
      flash[:error] = "Is that a valid URL?"
    end

    redirect_to new_shortlink_path
  end

  private

  def shortlink_params
    params.require(:shortlink).permit(:destination)
  end
end
