<%@ page import="com.smartlab.dao.PatientLabDAO" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"PATIENT".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+patient");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    String selectedCity = (String) request.getAttribute("selectedCity");
    String selectedLabName = (String) request.getAttribute("selectedLabName");
    String selectedSearchMode = (String) request.getAttribute("selectedSearchMode");
    if (selectedSearchMode == null || selectedSearchMode.isBlank()) {
        selectedSearchMode = "nearest";
    }
    String selectedSort = (String) request.getAttribute("selectedSort");
    if (selectedSort == null || selectedSort.isBlank()) {
        selectedSort = "NEAREST";
    }
    Double selectedLatitude = (Double) request.getAttribute("selectedLatitude");
    Double selectedLongitude = (Double) request.getAttribute("selectedLongitude");
    String error = (String) request.getAttribute("error");
    List<String> availableTests = (List<String>) request.getAttribute("availableTests");
    if (availableTests == null) availableTests = Collections.emptyList();
    Set<String> selectedTests = (Set<String>) request.getAttribute("selectedTests");
    if (selectedTests == null) selectedTests = Collections.emptySet();
    List<PatientLabDAO.BrowseLab> labs = (List<PatientLabDAO.BrowseLab>) request.getAttribute("labs");
    if (labs == null) labs = Collections.emptyList();
    String activePage = "labs";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Panel | Browse Labs</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .main {
            max-width: none;
        }
        h1 { margin: 0 0 16px; font-size: 1.8rem; }
        .box { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08); margin-bottom: 14px; }
        .error { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 10px; padding: 10px 12px; margin-bottom: 12px; }
        .mode { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
        .row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 10px; }
        input, select { width: 100%; border: 1px solid #d2deea; border-radius: 10px; padding: 10px 12px; font-size: 0.94rem; }
        .tests-box { border: 1px solid #d2deea; border-radius: 10px; padding: 10px; }
        .tests-box input[type="text"] { margin-bottom: 8px; border-radius: 8px; padding: 8px 10px; }
        .tests-list { max-height: 140px; overflow-y: auto; display: grid; gap: 6px; }
        .tests-list label { font-size: 0.92rem; color: #314a63; }
        .actions { display: flex; gap: 8px; margin-top: 12px; flex-wrap: wrap; }
        .adv { margin-top: 8px; }
        .adv-head { display: flex; justify-content: space-between; align-items: center; gap: 8px; }
        .adv-content { display: none; margin-top: 10px; }
        .btn { border: 0; border-radius: 10px; padding: 10px 14px; font-weight: 600; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #0b6bcb; color: #fff; }
        .btn-light { background: #e7eef7; color: #1e3550; }
        .results {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
            align-items: stretch;
            margin-top: 18px;
        }
        .lab-card {
            background: #fff;
            border-radius: 14px;
            padding: 16px;
            box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08);
            display: flex;
            flex-direction: column;
            min-height: 100%;
        }
        .lab-green { border: 2px solid #1f9d55; }
        .lab-red { border: 2px solid #d64545; }
        .lab-head {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            flex-wrap: wrap;
        }
        .lab-title {
            margin: 0 0 4px;
            font-size: 1.08rem;
        }
        .muted { color: #55708a; font-size: 0.92rem; }
        .meta {
            margin-top: 8px;
            font-size: 0.92rem;
            color: #36526f;
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }
        .chips {
            margin-top: 8px;
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }
        .chip {
            background: #edf4fc;
            color: #275077;
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 0.84rem;
        }
        .indicator {
            margin-top: 8px;
            font-size: 0.88rem;
            border-top: 1px solid #e6edf6;
            padding-top: 12px;
        }
        .ok-text { color: #1f7a43; font-weight: 600; }
        .bad-text { color: #b43333; font-weight: 600; }
        .lab-card-footer {
            margin-top: auto;
            padding-top: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }
        .lab-summary {
            font-size: 0.85rem;
            color: #6b839b;
        }
        @media (min-width: 1800px) {
            h1 {
                margin-bottom: 18px;
            }
            .box {
                padding: 18px;
            }
            .row {
                grid-template-columns: 1.2fr 1.2fr .8fr;
                gap: 12px;
            }
            .results {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 20px;
            }
            .lab-card {
                padding: 18px;
            }
        }
        @media (max-width: 1280px) {
            .box {
                padding: 14px;
            }
            .row {
                grid-template-columns: 1fr 1fr;
            }
            .results {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }
        @media (max-width: 1000px) {
            .row { grid-template-columns: 1fr; }
            .results { grid-template-columns: 1fr; }
        }
        @media (max-width: 900px) { .results { grid-template-columns: 1fr; } }
    </style>
    <%@ include file="includes/sidebar_styles.jspf" %>
</head>
<body>
<div class="layout">
    <%@ include file="includes/sidebar.jspf" %>

    <main class="main">
        <h1>Browse Labs</h1>
        <% if (error != null) { %><div class="error"><%= error %></div><% } %>

        <div class="box">
            <form method="get" action="<%= request.getContextPath() %>/FindLabsServlet" id="searchForm">
                <input type="hidden" name="search" value="1">
                <input type="hidden" name="latitude" id="latitude" value="<%= selectedLatitude == null ? "" : selectedLatitude %>">
                <input type="hidden" name="longitude" id="longitude" value="<%= selectedLongitude == null ? "" : selectedLongitude %>">

                <div class="mode">
                    <label><input type="radio" name="searchMode" value="nearest" <%= "nearest".equalsIgnoreCase(selectedSearchMode) ? "checked" : "" %>> Search by Nearest Labs</label>
                    <label><input type="radio" name="searchMode" value="city" <%= "city".equalsIgnoreCase(selectedSearchMode) ? "checked" : "" %>> Search by City</label>
                </div>

                <div class="row">
                    <input type="text" id="cityInput" name="city" placeholder="Enter city" value="<%= selectedCity == null ? "" : selectedCity %>">
                    <input type="text" name="labName" placeholder="Search by lab name (e.g. nepal)" value="<%= selectedLabName == null ? "" : selectedLabName %>">
                    <div></div>
                </div>

                <div class="adv">
                    <div class="adv-head">
                        <strong>Advanced Filters</strong>
                        <button id="toggleAdv" class="btn btn-light" type="button">Show</button>
                    </div>
                    <div id="advContent" class="adv-content">
                        <div class="row">
                            <select name="sort" id="sortInput">
                                <option value="NEAREST" <%= "NEAREST".equals(selectedSort) ? "selected" : "" %>>Nearest Labs</option>
                                <option value="PRICE_ASC" <%= "PRICE_ASC".equals(selectedSort) ? "selected" : "" %>>Price: Cheapest to Most Expensive</option>
                                <option value="RATING_DESC" <%= "RATING_DESC".equals(selectedSort) ? "selected" : "" %>>User Ratings: High to Low</option>
                            </select>
                        </div>
                        <div style="font-size:0.9rem;color:#56708a;margin:2px 0 6px;">
                            Optional: Search by multiple tests
                        </div>
                        <div class="tests-box">
                            <input type="text" id="testSearch" placeholder="Search tests to select multiple...">
                            <div class="tests-list" id="testsList">
                                <% for (String t : availableTests) { %>
                                <label data-test-name="<%= t.toLowerCase() %>">
                                    <input type="checkbox" name="tests" value="<%= t %>" <%= selectedTests.contains(t) ? "checked" : "" %>>
                                    <%= t %>
                                </label>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="actions">
                    <button class="btn btn-primary" type="submit">Search Labs</button>
                    <a class="btn btn-light" href="<%= request.getContextPath() %>/FindLabsServlet">Reset</a>
                </div>
            </form>
        </div>

        <div class="results">
            <% if (labs.isEmpty()) { %>
            <div class="box">No labs found for current filters.</div>
            <% } else { %>
            <% for (PatientLabDAO.BrowseLab lab : labs) { %>
            <%
                List<String> availableSelected = new ArrayList<>();
                List<String> missingSelected = new ArrayList<>();
                for (String s : selectedTests) {
                    if (lab.availableTests().contains(s)) availableSelected.add(s);
                    else missingSelected.add(s);
                }
                boolean hasSelected = !selectedTests.isEmpty();
                boolean allSelected = hasSelected && missingSelected.isEmpty();
                String cardClass = hasSelected ? (allSelected ? "lab-card lab-green" : "lab-card lab-red") : "lab-card";
            %>
            <div class="<%= cardClass %>">
                <div class="lab-head">
                    <div>
                        <h3 class="lab-title"><%= lab.labName() %></h3>
                        <div class="muted"><%= lab.city() %> | <%= lab.address() %></div>
                    </div>
                    <div class="muted">
                        <% if (lab.distanceKm() != null) { %>
                        Distance: <strong><%= String.format("%.2f", lab.distanceKm()) %> km</strong>
                        <% } else { %>
                        Distance: N/A
                        <% } %>
                    </div>
                </div>
                <div class="meta">
                    <span>Min Price: <strong>Rs. <%= lab.minPrice() %></strong></span>
                    <span>Rating: <strong><%= String.format("%.1f", lab.avgRating()) %></strong> (<%= lab.reviewCount() %> reviews)</span>
                    <span>Patients Served: <strong><%= lab.patientsServed() %></strong></span>
                </div>
                <div class="chips">
                    <% for (String test : lab.availableTests()) { %>
                    <span class="chip"><%= test %></span>
                    <% } %>
                </div>
                <% if (hasSelected) { %>
                <div class="indicator">
                    <% if (allSelected) { %>
                    <div class="ok-text">Provides all selected tests.</div>
                    <% } else { %>
                    <div class="bad-text">Missing one or more selected tests.</div>
                    <% } %>
                    <div><strong>Available from selected:</strong> <%= availableSelected.isEmpty() ? "None" : String.join(", ", availableSelected) %></div>
                    <div><strong>Missing from selected:</strong> <%= missingSelected.isEmpty() ? "None" : String.join(", ", missingSelected) %></div>
                </div>
                <% } %>
                <div class="lab-card-footer">
                    <div class="lab-summary"><%= lab.availableTests().size() %> tests available</div>
                    <a class="btn btn-primary" target="_blank"
                       href="<%= request.getContextPath() %>/BookAppointmentServlet?labId=<%= lab.id() %>">
                        Book Tests
                    </a>
                </div>
            </div>
            <% } %>
            <% } %>
        </div>
    </main>
</div>

<script>
    (function () {
        var form = document.getElementById("searchForm");
        var latInput = document.getElementById("latitude");
        var lngInput = document.getElementById("longitude");
        var cityInput = document.getElementById("cityInput");
        var sortInput = document.getElementById("sortInput");
        var toggleAdv = document.getElementById("toggleAdv");
        var advContent = document.getElementById("advContent");
        var modeInputs = document.querySelectorAll("input[name='searchMode']");
        var testSearch = document.getElementById("testSearch");
        var testLabels = document.querySelectorAll("#testsList label");
        var waitingForLocation = false;

        function getMode() {
            for (var i = 0; i < modeInputs.length; i++) {
                if (modeInputs[i].checked) return modeInputs[i].value;
            }
            return "nearest";
        }

        function syncModeUI() {
            var mode = getMode();
            var isNearest = mode === "nearest";
            cityInput.disabled = isNearest;
            if (isNearest) {
                cityInput.value = "";
                sortInput.value = "NEAREST";
            } else {
                latInput.value = "";
                lngInput.value = "";
                if (sortInput.value === "NEAREST") {
                    sortInput.value = "PRICE_ASC";
                }
            }
        }

        modeInputs.forEach(function (input) {
            input.addEventListener("change", syncModeUI);
        });
        syncModeUI();

        toggleAdv.addEventListener("click", function () {
            var open = advContent.style.display === "block";
            advContent.style.display = open ? "none" : "block";
            toggleAdv.textContent = open ? "Show" : "Hide";
        });

        form.addEventListener("submit", function (event) {
            var mode = getMode();
            if (mode !== "nearest" || waitingForLocation) {
                return;
            }
            event.preventDefault();
            if (!navigator.geolocation) {
                alert("Geolocation is not supported in this browser.");
                return;
            }
            navigator.geolocation.getCurrentPosition(function (pos) {
                latInput.value = pos.coords.latitude;
                lngInput.value = pos.coords.longitude;
                waitingForLocation = true;
                form.submit();
            }, function () {
                alert("Location access denied. Choose Search by City instead.");
            }, {enableHighAccuracy: true, timeout: 10000, maximumAge: 0});
        });

        testSearch.addEventListener("input", function () {
            var q = testSearch.value.trim().toLowerCase();
            testLabels.forEach(function (label) {
                var name = label.getAttribute("data-test-name");
                label.style.display = name.indexOf(q) >= 0 ? "block" : "none";
            });
        });
    })();
</script>
</body>
</html>




