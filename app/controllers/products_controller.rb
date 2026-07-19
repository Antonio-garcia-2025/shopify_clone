class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = current_user.products
    @product = current_user.products.build
  end

  def create
    # 1. Buscamos si ya existe el producto por nombre
    @product = current_user.products.find_by("lower(name) = ?", product_params[:name].downcase)
    
    if @product
      # 2. Calculamos el nuevo stock sumando el actual y el que viene del formulario
      new_stock = @product.stock + 1
      
      if @product.update(stock: new_stock, price: product_params[:price])
        redirect_to root_path, notice: "Stock updated successfully!"
      else
        @products = current_user.products
        render :index, status: :unprocessable_entity
      end
    else
      # 3. Si el producto no existe, creamos uno nuevo
      @product = current_user.products.build(product_params)
      @product.stock = 1 # Inicializamos el stock en 1 para un nuevo producto
      
      if @product.save
        redirect_to root_path, notice: "Product created successfully!"
      else
        @products = current_user.products
        render :index, status: :unprocessable_entity
      end
    end 
  end # <-- Este cierra el método create

  def sell
    @product = current_user.products.find(params[:id])
    
    if @product.stock > 0
      @product.stock -= 1

      if @product.save
        redirect_to root_path, notice: "Product sold successfully!"
      else
        redirect_to root_path, alert: "Error selling product."
      end
    else   
      redirect_to root_path, alert: "No stock available to sell."
    end
  end # <-- Este cierra el método sell

  def destroy
    # Blindaje de seguridad: Solo busca dentro de los productos del usuario actual
    @product = current_user.products.find(params[:id])
    @product.destroy
    redirect_to root_path, status: :see_other, notice: 'Product was successfully deleted.'
  end # <-- Este cierra el método destroy

  private

  def product_params
    params.require(:product).permit(:name, :price, :stock)
  end 
end # <-- Este cierra la clase global ProductsController