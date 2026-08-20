require "csv"

class ProductsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_product, only: [:edit, :update, :sell, :destroy]

  def index
    @categories = current_user.categories

    @products = current_user.products
    if params[:query].present?
      @products = @products.where("lower(name) LIKE ?", "%#{params[:query].downcase}%")
    end

    @product = current_user.products.build

    # Métricas del dashboard
    @total_earnings = current_user.sales.sum(:price) || 0
    @inventory_value = current_user.products.sum("COALESCE(price, 0) * COALESCE(stock, 0)")
    @out_of_stock_count = current_user.products.where("COALESCE(stock, 0) = 0").count

    # Historial de ventas
    @recent_sales = current_user.sales.includes(:product).order(created_at: :desc).limit(10)

    # 📥 Descarga CSV o Render HTML
    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv(@products),
                  filename: "inventario_#{Time.zone.today.strftime('%Y%m%d')}.csv",
                  type: "text/csv; charset=utf-8",
                  disposition: "attachment"
      end
    end
  end

  def create
    @product = current_user.products.find_by("lower(name) = ?", product_params[:name].downcase)
    
    if @product
      new_stock = (@product.stock || 0) + 1
      
      if @product.update(stock: new_stock, price: product_params[:price])
        redirect_to root_path, notice: "¡Stock actualizado con éxito!"
      else
        load_dashboard_data
        render :index, status: :unprocessable_entity
      end
    else
      @product = current_user.products.build(product_params)
      @product.stock = 1
      
      if @product.save
        redirect_to root_path, notice: "¡Producto creado con éxito!"
      else
        load_dashboard_data
        render :index, status: :unprocessable_entity
      end
    end 
  end

  def edit
    @categories = current_user.categories
  end

  def update
    if @product.update(product_params)
      redirect_to root_path, notice: "¡Producto actualizado correctamente!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def sell
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
    @product.destroy
    redirect_to root_path, status: :see_other, notice: 'Product was successfully deleted.'
  end

  private

  def set_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :stock, :category_id)
  end 

  def load_dashboard_data
    @products = current_user.products
    if params[:query].present?
      @products = @products.where("lower(name) LIKE ?", "%#{params[:query].downcase}%")
    end
    @total_earnings = current_user.sales.sum(:price) || 0
    @inventory_value = current_user.products.sum("COALESCE(price, 0) * COALESCE(stock, 0)")
    @out_of_stock_count = current_user.products.where("COALESCE(stock, 0) = 0").count
    @recent_sales = current_user.sales.includes(:product).order(created_at: :desc).limit(10)
  end

  def generate_csv(products)
    CSV.generate(headers: true) do |csv|
      csv << ["ID", "Producto", "Precio Unitario ($)", "Stock", "Valor Total ($)", "Fecha Registro"]
      products.each do |prod|
        total_val = (prod.price.to_f * prod.stock.to_i).round(2)
        fecha_formateada = prod.created_at&.strftime("%d/%m/%Y %H:%M") || "Sin fecha"
        csv << [prod.id, prod.name, prod.price, prod.stock, total_val, fecha_formateada]
      end
    end
  end
end