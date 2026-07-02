// ======================================
// STAR UNIVERSAL TRADE (SUT)
// PRODUCTS.JS
// ======================================

import { saveProduct, getProducts } from "../firebase/firebase.js";

// ----------------------------
// ADD PRODUCT
// ----------------------------
window.uploadProduct = async () => {

    if (!window.currentUser) {
        alert("Tafadhali login kwanza.");
        return;
    }

    const title = document.getElementById("product-title").value.trim();
    const price = document.getElementById("product-price").value.trim();
    const description = document.getElementById("product-description").value.trim();
    const category = document.getElementById("product-category").value.trim();

    if (!title || !price) {
        alert("Jaza Title na Price.");
        return;
    }

    const product = {

        title,
        price: Number(price),
        description,
        category,

        sellerId: window.currentUser.uid,
        sellerEmail: window.currentUser.email,

        country: "Tanzania",

        status: "active"

    };

    try {

        await saveProduct(product);

        alert("✅ Product Uploaded");

        clearForm();

        loadProducts();

    } catch (error) {

        alert(error.message);

    }

};

// ----------------------------
// CLEAR FORM
// ----------------------------
function clearForm() {

    document.getElementById("product-title").value = "";
    document.getElementById("product-price").value = "";
    document.getElementById("product-description").value = "";
    document.getElementById("product-category").value = "";

}

// ----------------------------
// LOAD PRODUCTS
// ----------------------------
window.loadProducts = async () => {

    const container = document.getElementById("products-container");

    if (!container) return;

    container.innerHTML = "Loading...";

    try {

        const products = await getProducts();

        if (products.length === 0) {

            container.innerHTML = "<h3>No Products</h3>";

            return;

        }

        container.innerHTML = "";

        products.forEach(product => {

            container.innerHTML += `

            <div class="product-card">

                <h3>${product.title}</h3>

                <p><strong>Price:</strong> ${product.price}</p>

                <p>${product.description || ""}</p>

                <small>${product.category || ""}</small>

            </div>

            `;

        });

    } catch (error) {

        container.innerHTML = error.message;

    }

};

// ----------------------------
// AUTO LOAD
// ----------------------------
document.addEventListener("DOMContentLoaded", () => {

    loadProducts();

});
