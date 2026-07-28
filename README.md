# Shopify Clone - Inventory, Sales & Financial Dashboard

Un sistema de gestión de inventarios, simulación de ventas y panel de métricas financieras multi-inquilino (*multi-tenant*) desarrollado con **Ruby on Rails 8**. Cada comerciante cuenta con un entorno seguro y aislado para administrar su stock, procesar transacciones en tiempo real y monitorear el desempeño de su negocio.

## 🚀 Características del Proyecto

- **Autenticación Segura:** Implementada con Devise para el registro e inicio de sesión de usuarios.
- **Aislamiento de Datos (Multi-tenancy):** Los comerciantes solo pueden ver, editar y vender sus propios productos y transacciones.
- **Inventario Inteligente:** Al registrar un producto con un nombre ya existente, el sistema incrementa automáticamente el stock en lugar de duplicar el registro y actualiza el precio al más reciente.
- **Motor de Ventas Express & Transacciones:** Botón funcional para descontar stock unidad por unidad mediante transacciones atómicas (`ActiveRecord::Base.transaction`), registrando la venta en un modelo independiente (`Sale`).
- **Dashboard Financiero en Tiempo Real:**
  - 💰 **Ventas Totales:** Suma acumulada de los ingresos reales por ventas.
  - 📦 **Valor en Inventario:** Cálculo del capital retenido en stock (`precio * stock`).
  - ⚠️ **Productos Agotados:** Alerta visual e indicador numérico de artículos sin existencias.
- **Seguridad y Resiliencia en Consultas:** Consultas SQL blindadas con `COALESCE` para prevenir errores por datos nulos y restricciones a nivel de controlador (`current_user.products`).

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