// ===============================
// STAR UNIVERSAL TRADE (SUT)
// Authentication Controller
// ===============================

document.addEventListener("DOMContentLoaded", () => {

    // REGISTER
    const registerForm = document.getElementById("register-form");

    if (registerForm) {

        registerForm.addEventListener("submit", async (e) => {

            e.preventDefault();

            const email = document.getElementById("register-email").value.trim();
            const password = document.getElementById("register-password").value;

            await window.registerWithEmail(email, password);

        });

    }

    // LOGIN
    const loginForm = document.getElementById("login-form");

    if (loginForm) {

        loginForm.addEventListener("submit", async (e) => {

            e.preventDefault();

            const email = document.getElementById("login-email").value.trim();
            const password = document.getElementById("login-password").value;

            await window.loginWithEmail(email, password);

        });

    }

    // GOOGLE LOGIN
    const googleBtn = document.getElementById("google-login");

    if (googleBtn) {

        googleBtn.addEventListener("click", async () => {

            await window.loginWithGoogle();

        });

    }

    // LOGOUT
    const logoutBtn = document.getElementById("logout-btn");

    if (logoutBtn) {

        logoutBtn.addEventListener("click", async () => {

            await window.logoutUser();

        });

    }

});
