class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:edit, :update, :destroy, :sell]

  def index
    # Auto-crear categorías por defecto si el usuario no tiene ninguna
    if current_user.categories.empty?
      ["Ropa", "Electrónica", "Alimentos", "Hogar", "Calzado"].each do |cat_name|
        current_user.categories.find_or_create_by(name: cat_name)
      end
    end

    @categories = current_user.categories
    @product = current_user.products.build

    # Filtros y búsqueda
    @products = current_user.products.includes(:category).order(created_at: :desc)
    @products = @products.where("LOWER(name) LIKE ?", "%#{params[:query].downcase}%") if params[:query].present?
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

    # Métricas del Dashboard
    @total_earnings = current_user.sales.sum(:price)
    @inventory_value = current_user.products.sum("price * stock")
    @out_of_stock_count = current_user.products.where(stock: 0).count
    @recent_sales = current_user.sales.includes(:product).order(created_at: :desc).limit(10)

    respond_to do |format|
      format.html
      format.csv do
        send_data current_user.products.to_csv,
                  filename: "inventario-#{Date.today}.csv",
                  type: "text/csv; charset=utf-8"
      end
    end
  end

  def create
    # Limpiamos el nombre ingresado
    clean_name = product_params[:name].to_s.strip
    incoming_stock = product_params[:stock].present? ? product_params[:stock].to_i : 1

    # 1. Buscamos si el usuario ya tiene registrado un producto con ese mismo nombre
    existing_product = current_user.products.where("LOWER(name) = ?", clean_name.downcase).first

    if existing_product
      # 2. Si ya existe, sumamos al stock existente y actualizamos precio/categoría si se indicaron
      existing_product.stock = existing_product.stock.to_i + incoming_stock
      existing_product.price = product_params[:price] if product_params[:price].present?
      existing_product.category_id = product_params[:category_id] if product_params[:category_id].present?

      if existing_product.save
        redirect_to root_path, notice: "¡'#{existing_product.name}' ya existía! Se sumaron #{incoming_stock} unidad(es) al stock (Total: #{existing_product.stock})."
      else
        cargar_datos_index
        render :index, status: :unprocessable_entity
      end
    else
      # 3. Si no existe, lo creamos desde cero con stock inicial de 1
      @product = current_user.products.build(product_params)
      @product.stock = incoming_stock if @product.stock.blank? || @product.stock.zero?

      if @product.save
        redirect_to root_path, notice: "¡Producto '#{@product.name}' creado exitosamente con #{incoming_stock} unidad(es)!"
      else
        cargar_datos_index
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
      @categories = current_user.categories
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to root_path, notice: "Producto eliminado correctamente."
  end

  def sell
    if @product.stock.to_i > 0
      Product.transaction do
        @product.decrement!(:stock)
        current_user.sales.create!(product: @product, price: @product.price)
      end
      redirect_to root_path, notice: "¡Venta registrada con éxito de #{@product.name}!"
    else
      redirect_to root_path, alert: "No hay existencias disponibles para vender este producto."
    end
  end

  private

  def set_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :stock, :category_id)
  end
end