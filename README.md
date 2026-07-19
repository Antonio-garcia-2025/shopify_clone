# README
# Shopify - Inventory & Sales Management

Un sistema de gestión de inventarios y simulación de ventas multi-inquilino (*multi-tenant*) desarrollado con **Ruby on Rails 8**. Cada comerciante cuenta con un entorno seguro y aislado para administrar su stock y procesar transacciones en tiempo real.

## Características del Proyecto

- **Autenticación Segura:** Implementada con Devise para el registro e inicio de sesión de usuarios.
- **Aislamiento de Datos (Multi-tenancy):** Los comerciantes solo pueden ver, editar y vender sus propios productos.
- **Inventario Inteligente:** Al registrar un producto con un nombre ya existente, el sistema incrementa automáticamente el stock en lugar de duplicar el registro y actualiza el precio al más reciente.
- **Motor de Ventas Express:** Botón funcional para descontar stock unidad por unidad con validación visual instantánea (*AGOTADO*) al llegar a cero.
- **Seguridad en Controladores:** Restricción a nivel de base de datos y controladores (`current_user.products`) para evitar vulnerabilidades de acceso cruzado.

## 🛠️ Tecnologías Utilizadas

- **Backend:** Ruby on Rails 8.1.3
- **Base de Datos:** SQLite3
- **Autenticación:** Devise Gem
- **Frontend:** HTML5, Embedded Ruby (ERB) y estilos nativos.

## 📦 Instalación y Uso Local

1. Clonar el repositorio.
2. Instalar las dependencias del proyecto:
   ```bash
   bundle install
