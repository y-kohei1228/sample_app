class MicropostsController < ApplicationController
  before_action :logged_in_user,  only: %i[create destroy]
  before_action :correct_user,    only: :destroy

  def show
    @micropost = Micropost.find(params[:id])
    @reply = current_user&.microposts&.build
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = 'Micropost created!'
      if @micropost.parent.present?
        redirect_to micropost_path(@micropost.parent)
      else
        redirect_to root_url
      end
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_content
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = 'Micropost deleted'
    redirect_back_or_to(root_url, status: :see_other)
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image, :parent_id)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url, status: :see_other if @micropost.nil?
  end
end
