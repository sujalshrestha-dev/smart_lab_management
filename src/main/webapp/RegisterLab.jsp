<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab Staff Registration | Smart Lab</title>
    <link
            rel="stylesheet"
            href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
            integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
            crossorigin=""
    />
    <style>
        :root {
            --text: #203a69;
            --muted: #5d7194;
            --primary: #2f66d8;
            --primary-hover: #2458c5;
            --border: #cfdbef;
            --card-bg: rgba(246, 250, 255, 0.42);
            --card-border: rgba(255, 255, 255, 0.52);
            --field-bg: rgba(255, 255, 255, 0.9);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: "Segoe UI", "Trebuchet MS", Tahoma, Geneva, Verdana, sans-serif;
            background:
                linear-gradient(180deg, rgba(220, 235, 255, 0.5) 0%, rgba(198, 221, 255, 0.38) 100%),
                url("assets/images/Model/medical.png") center/cover no-repeat fixed;
            color: var(--text);
            min-height: 100vh;
            display: grid;
            place-items: center;
            padding: clamp(10px, 3vw, 24px);
        }

        .card {
            width: min(980px, 100%);
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: clamp(16px, 3.4vw, 30px) clamp(14px, 3.8vw, 34px) clamp(16px, 3.2vw, 24px);
            box-shadow: 0 24px 52px rgba(29, 54, 104, 0.24);
            backdrop-filter: blur(8px);
        }

        .brand {
            display: grid;
            justify-items: center;
            gap: 4px;
            margin-bottom: 12px;
        }

        .brand-logo {
            width: clamp(96px, 22vw, 170px);
            height: auto;
            object-fit: contain;
        }

        h1 {
            font-size: clamp(1.35rem, 3.8vw, 2.05rem);
            margin-bottom: 6px;
            text-align: center;
        }

        .subtitle {
            color: var(--muted);
            margin-bottom: 14px;
            text-align: center;
            font-size: clamp(0.88rem, 2vw, 1.02rem);
        }

        form {
            display: grid;
            gap: 14px;
        }

        .row {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .field {
            display: grid;
            gap: 6px;
        }

        label {
            font-size: clamp(0.9rem, 2vw, 1rem);
            font-weight: 700;
            color: #2e4a78;
        }

        input,
        textarea {
            width: 100%;
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 10px 12px;
            font-size: clamp(0.94rem, 2vw, 1rem);
            outline: none;
            background: var(--field-bg);
        }

        input:focus,
        textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(47, 102, 216, 0.14);
        }

        textarea {
            resize: vertical;
            min-height: 68px;
        }

        .password-wrap {
            position: relative;
        }

        .toggle-password {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            border: 0;
            background: transparent;
            color: var(--muted);
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 600;
            padding: 2px 4px;
        }

        .password-wrap input {
            padding-right: 64px;
        }

        #map {
            width: 100%;
            height: clamp(220px, 40vw, 320px);
            border: 1px solid var(--border);
            border-radius: 12px;
            overflow: hidden;
        }

        .map-hint {
            color: var(--muted);
            font-size: 0.9rem;
            margin-top: 8px;
        }

        .search-wrap {
            display: grid;
            gap: 8px;
        }

        .search-row {
            display: flex;
            gap: 8px;
        }

        .search-row input {
            flex: 1;
        }

        .search-results {
            list-style: none;
            border: 1px solid var(--border);
            border-radius: 10px;
            overflow: hidden;
            max-height: 180px;
            overflow-y: auto;
            display: none;
        }

        .search-results li {
            padding: 10px 12px;
            border-bottom: 1px solid var(--border);
            background: #fff;
            cursor: pointer;
            font-size: 0.9rem;
        }

        .search-results li:last-child {
            border-bottom: 0;
        }

        .search-results li:hover {
            background: #f2f7fd;
        }

        .map-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 10px;
        }

        .actions {
            display: flex;
            gap: 10px;
            margin-top: 8px;
        }

        .btn {
            border: 0;
            border-radius: 10px;
            padding: 10px 16px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            font-size: clamp(0.92rem, 2vw, 1rem);
        }

        .btn-primary {
            background: var(--primary);
            color: #fff;
        }

        .btn-primary:hover {
            background: var(--primary-hover);
        }

        .btn-light {
            background: #e8effb;
            color: var(--text);
        }

        .btn[disabled] {
            opacity: 0.55;
            cursor: not-allowed;
        }

        .login-note {
            margin-top: 8px;
            font-size: 0.95rem;
            color: var(--muted);
        }

        .login-note a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }

        .error {
            color: #b42318;
            font-size: 0.84rem;
            display: none;
        }

        .flash {
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 0.92rem;
            margin-bottom: 8px;
        }

        .flash.error {
            display: block;
            background: #fdecec;
            color: #8f1e15;
            border: 1px solid #f8c9c4;
        }

        .flash.success {
            display: block;
            background: #eaf8ee;
            color: #106b36;
            border: 1px solid #bee8ca;
        }

        .readonly {
            background: #f6f9fc;
        }

        @media (max-width: 840px) {
            body { background-attachment: scroll; }
            .card { border-radius: 16px; }
            .row { grid-template-columns: 1fr; }
            .search-row { flex-direction: column; }
            .search-row button { width: 100%; }
            .map-actions button { flex: 1; min-width: 140px; }
            .actions .btn { flex: 1; min-width: 140px; text-align: center; }
        }

        @media (max-width: 440px) {
            .map-actions button,
            .actions .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<main class="card">
    <div class="brand">
        <img class="brand-logo" src="assets/images/logo.png" alt="SmartLab logo">
    </div>
    <h1>Lab Staff Registration</h1>
    <p class="subtitle">Enter account and lab details, then confirm your location on map</p>
    <% if (error != null && !error.isBlank()) { %>
    <p class="flash error"><%= esc(error) %></p>
    <% } %>
    <% if (success != null && !success.isBlank()) { %>
    <p class="flash success"><%= esc(success) %></p>
    <% } %>

    <form action="RegisterServlet" method="post" id="labRegisterForm">
        <input type="hidden" name="role" value="LAB_STAFF">

        <div class="row">
            <div class="field">
                <label for="fullName">Full Name</label>
                <input type="text" id="fullName" name="fullName" maxlength="100" required>
            </div>
            <div class="field">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" maxlength="50" required>
            </div>
        </div>
        <p class="error" id="usernameError">Username must not start with a number and can only use letters, numbers, and underscore (_).</p>

        <div class="row">
            <div class="field">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" maxlength="120" required>
            </div>
            <div class="field">
                <label for="contactNumber">Contact Number</label>
                <input type="text" id="contactNumber" name="contactNumber" maxlength="25" required>
            </div>
        </div>

        <div class="row">
            <div class="field">
                <label for="password">Password</label>
                <div class="password-wrap">
                    <input type="password" id="password" name="password" required>
                    <button type="button" class="toggle-password" id="togglePasswords" aria-label="Show passwords">Eye</button>
                </div>
            </div>
            <div class="field">
                <label for="confirmPassword">Confirm Password</label>
                <div class="password-wrap">
                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                </div>
            </div>
        </div>
        <p class="error" id="passwordError">Password must include uppercase, lowercase, one symbol, and at least two numbers (min 8 chars).</p>

        <div class="row">
            <div class="field">
                <label for="labName">Lab Name</label>
                <input type="text" id="labName" name="labName" maxlength="120" required>
            </div>
            <div class="field">
                <label for="city">City</label>
                <input type="text" id="city" name="city" maxlength="80" required>
            </div>
        </div>

        <div class="field">
            <label for="address">Address</label>
            <textarea id="address" name="address" maxlength="255" required></textarea>
        </div>

        <div class="field">
            <label>Pick Lab Location</label>
            <div class="search-wrap">
                <div class="search-row">
                    <input type="text" id="locationSearch" placeholder="Search place name (e.g., Baneshwor, Kathmandu)">
                    <button type="button" class="btn btn-light" id="searchBtn">Search</button>
                </div>
                <ul id="searchResults" class="search-results"></ul>
            </div>
            <div id="map"></div>
            <p class="map-hint" id="mapStatus">Click on the map to drop a pin, then click Confirm Point.</p>
            <div class="map-actions">
                <button type="button" class="btn btn-light" id="useCurrentLocationBtn">Use Current Location</button>
                <button type="button" class="btn btn-primary" id="confirmPointBtn" disabled>Confirm Point</button>
                <button type="button" class="btn btn-light" id="backPointBtn" disabled>Back</button>
            </div>
        </div>

        <div class="row">
            <div class="field">
                <label for="latitude">Latitude</label>
                <input type="text" id="latitude" name="latitude" class="readonly" readonly required>
            </div>
            <div class="field">
                <label for="longitude">Longitude</label>
                <input type="text" id="longitude" name="longitude" class="readonly" readonly required>
            </div>
        </div>

        <div class="actions">
            <button type="submit" class="btn btn-primary" id="submitBtn" disabled>Register Lab</button>
            <a href="index.jsp" class="btn btn-light">Back to Home</a>
        </div>
        <p class="login-note">Already have an account? <a href="login.jsp">Login.</a></p>
    </form>
</main>

<script
        src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
        crossorigin=""
></script>
<script>
    (function () {
        var map = L.map("map").setView([27.7172, 85.3240], 12);
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(map);

        var marker = null;
        var selectedLat = null;
        var selectedLng = null;
        var confirmed = false;

        var confirmBtn = document.getElementById("confirmPointBtn");
        var backBtn = document.getElementById("backPointBtn");
        var useCurrentLocationBtn = document.getElementById("useCurrentLocationBtn");
        var submitBtn = document.getElementById("submitBtn");
        var latInput = document.getElementById("latitude");
        var lngInput = document.getElementById("longitude");
        var statusText = document.getElementById("mapStatus");
        var form = document.getElementById("labRegisterForm");
        var username = document.getElementById("username");
        var password = document.getElementById("password");
        var confirmPassword = document.getElementById("confirmPassword");
        var usernameError = document.getElementById("usernameError");
        var passwordError = document.getElementById("passwordError");
        var togglePasswords = document.getElementById("togglePasswords");
        var searchInput = document.getElementById("locationSearch");
        var searchBtn = document.getElementById("searchBtn");
        var searchResults = document.getElementById("searchResults");
        var usernameRegex = /^[A-Za-z_][A-Za-z0-9_]*$/;
        var passwordRegex = /^(?=(?:.*\d){2,})(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$/;

        togglePasswords.addEventListener("click", function () {
            var show = password.type === "password";
            password.type = show ? "text" : "password";
            confirmPassword.type = show ? "text" : "password";
            togglePasswords.textContent = show ? "Hide" : "Eye";
        });

        map.on("click", function (event) {
            if (confirmed) {
                return;
            }

            selectedLat = event.latlng.lat;
            selectedLng = event.latlng.lng;

            if (marker) {
                marker.setLatLng(event.latlng);
            } else {
                marker = L.marker(event.latlng).addTo(map);
            }

            confirmBtn.disabled = false;
            statusText.textContent = "Point selected. Click Confirm Point to lock coordinates.";
        });

        function clearResults() {
            searchResults.innerHTML = "";
            searchResults.style.display = "none";
        }

        function placeMarker(lat, lng, label) {
            selectedLat = lat;
            selectedLng = lng;
            var latLng = L.latLng(lat, lng);

            if (marker) {
                marker.setLatLng(latLng);
            } else {
                marker = L.marker(latLng).addTo(map);
            }

            map.setView(latLng, 16);
            confirmBtn.disabled = false;
            statusText.textContent = label ? "Selected: " + label + ". Click Confirm Point to lock coordinates." : "Point selected. Click Confirm Point to lock coordinates.";
        }

        async function searchLocation() {
            var query = searchInput.value.trim();
            if (!query) {
                clearResults();
                return;
            }

            searchBtn.disabled = true;
            searchBtn.textContent = "Searching...";
            clearResults();

            try {
                var url = "https://nominatim.openstreetmap.org/search?format=json&limit=6&q=" + encodeURIComponent(query);
                var response = await fetch(url, {
                    headers: {
                        "Accept": "application/json"
                    }
                });

                if (!response.ok) {
                    throw new Error("Search failed");
                }

                var data = await response.json();
                if (!data.length) {
                    statusText.textContent = "No places found. Try a different keyword.";
                    return;
                }

                data.forEach(function (item) {
                    var li = document.createElement("li");
                    li.textContent = item.display_name;
                    li.addEventListener("click", function () {
                        if (confirmed) {
                            return;
                        }
                        placeMarker(parseFloat(item.lat), parseFloat(item.lon), item.display_name);
                        clearResults();
                    });
                    searchResults.appendChild(li);
                });

                searchResults.style.display = "block";
            } catch (error) {
                statusText.textContent = "Search is currently unavailable. You can still click on the map.";
            } finally {
                searchBtn.disabled = false;
                searchBtn.textContent = "Search";
            }
        }

        searchBtn.addEventListener("click", function () {
            searchLocation();
        });

        searchInput.addEventListener("keydown", function (event) {
            if (event.key === "Enter") {
                event.preventDefault();
                searchLocation();
            }
        });

        useCurrentLocationBtn.addEventListener("click", function () {
            if (confirmed) {
                return;
            }

            if (!navigator.geolocation) {
                statusText.textContent = "Geolocation is not supported by this browser.";
                return;
            }

            useCurrentLocationBtn.disabled = true;
            useCurrentLocationBtn.textContent = "Locating...";
            statusText.textContent = "Getting your current location...";

            navigator.geolocation.getCurrentPosition(function (position) {
                placeMarker(position.coords.latitude, position.coords.longitude, "Current location");
                useCurrentLocationBtn.disabled = false;
                useCurrentLocationBtn.textContent = "Use Current Location";
            }, function () {
                statusText.textContent = "Unable to get current location. Allow location permission or pick on map.";
                useCurrentLocationBtn.disabled = false;
                useCurrentLocationBtn.textContent = "Use Current Location";
            }, {
                enableHighAccuracy: true,
                timeout: 10000
            });
        });

        confirmBtn.addEventListener("click", function () {
            if (selectedLat === null || selectedLng === null) {
                return;
            }

            latInput.value = selectedLat.toFixed(7);
            lngInput.value = selectedLng.toFixed(7);
            confirmed = true;
            submitBtn.disabled = false;
            backBtn.disabled = false;
            confirmBtn.disabled = true;
            statusText.textContent = "Location confirmed. Click Back to re-select.";
        });

        backBtn.addEventListener("click", function () {
            confirmed = false;
            latInput.value = "";
            lngInput.value = "";
            submitBtn.disabled = true;
            backBtn.disabled = true;

            if (selectedLat !== null && selectedLng !== null) {
                confirmBtn.disabled = false;
                statusText.textContent = "Selection unlocked. Move pin by clicking map, then confirm again.";
            } else {
                confirmBtn.disabled = true;
                statusText.textContent = "Click on the map to drop a pin, then click Confirm Point.";
            }
        });

        form.addEventListener("submit", function (event) {
            var valid = true;

            if (!usernameRegex.test(username.value.trim())) {
                usernameError.style.display = "block";
                valid = false;
            } else {
                usernameError.style.display = "none";
            }

            if (!passwordRegex.test(password.value)) {
                passwordError.style.display = "block";
                password.focus();
                valid = false;
            } else if (password.value !== confirmPassword.value) {
                passwordError.style.display = "block";
                confirmPassword.focus();
                valid = false;
            } else {
                passwordError.style.display = "none";
            }

            if (!latInput.value || !lngInput.value) {
                valid = false;
                alert("Please confirm a location point on the map before submitting.");
            }

            if (!valid) {
                event.preventDefault();
            }
        });
    })();
</script>
</body>
</html>
