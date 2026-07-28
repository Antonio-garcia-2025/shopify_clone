class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = current_user.products
    @product = current_user.products.build

    # Métricas del dashboard (protegidas contra NULL)
    @total_earnings = current_user.sales.sum(:price) || 0
    @inventory_value = @products.sum("COALESCE(price, 0) * COALESCE(stock, 0)")
    @out_of_stock_count = @products.where("COALESCE(stock, 0) = 0").count
  end

  def create
    @product = current_user.products.find_by("lower(name) = ?", product_params[:name].downcase)
    
    if @product
      new_stock = (@product.stock || 0) + 1
      
      if @product.update(stock: new_stock, price: product_params[:price])
        redirect_to root_path, notice: "Stock updated successfully!"
      else
        load_dashboard_data
        render :index, status: :unprocessable_entity
      end
    else
      @product = current_user.products.build(product_params)
      @product.stock = 1
      
      if @product.save
        redirect_to root_path, notice: "Product created successfully!"
      else
        load_dashboard_data
        render :index, status: :unprocessable_entity
      end
    end 
  end

  def sell
    @product = current_user.products.find(params[:id])
    
    if (@product.stock || 0) > 0
      @product.stock -= 1

      ActiveRecord::Base.transaction do
        @product.save!
        current_user.sales.create!(product: @product, price: @product.price)
      end

      redirect_to root_path, notice: "Product sold successfully!"
    else   
      redirect_to root_path, alert: "No stock available to sell."
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to root_path, alert: "Error selling product."
  end

  def destroy
    @product = current_user.products.find(params[:id])
    @product.destroy
    redirect_to root_path, status: :see_other, notice: 'Product was successfully deleted.'
  end

  private

  def product_params
    params.require(:product).permit(:name, :price, :stock)
  end 

  def load_dashboard_data
    @products = current_user.products
    @total_earnings = current_user.sales.sum(:price) || 0
    @inventory_value = @products.sum("COALESCE(price, 0) * COALESCE(stock, 0)")
    @out_of_stock_count = @products.where("COALESCE(stock, 0) = 0").count
  end
end