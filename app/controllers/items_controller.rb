class ItemsController < ApplicationController

  def index
    # raise
    @items = policy_scope(Item).all
    if params[:search]
      @items = Item.where("name LIKE ?", "%#{ params[:search][:query].downcase}%")
    end
  end

  def show
    #@user = User.find(params[:user_id])
    @item = Item.find(params[:id])
    @offers = @item.offers
    @offer = Offer.new
    authorize @item

    accepted_offer = @offers.find_by(status: "Offer accepted")
    if accepted_offer
      @offers.where.not(id: accepted_offer.id).update_all(status: "Offer closed")
      accepted_offer.item.update(status: "sold")
    end
  end

  def new
    @user = current_user
    @item = Item.new
    authorize @item
  end

  def create
    @user = current_user
    @item = Item.new(item_params)
    @item.user = @user
    authorize @item

    if @item.save
      redirect_to user_path(@user), notice: "Item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def category
    @items = Item.where(category: params[:category])
    authorize @items
  end

  def destroy
    @item = Item.find(params[:id])
    authorize @item
    @item.destroy
    redirect_to user_path(@item.user), notice: "Item was successfully removed.", status: :see_other
  end

  private
  def item_params
    params.require(:item).permit(:price, :category, :name, :description, :status, photos: [])
  end
end
