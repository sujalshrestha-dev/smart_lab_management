<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Redirecting to eSewa</title>
    <style>
        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: #f3f8ff;
            color: #17314c;
        }
        .card {
            width: min(92vw, 480px);
            background: #fff;
            border-radius: 14px;
            padding: 22px;
            box-shadow: 0 12px 24px rgba(22, 49, 76, 0.12);
            text-align: center;
        }
        .muted {
            color: #567189;
            font-size: 0.95rem;
            margin-top: 8px;
        }
        .btn {
            margin-top: 16px;
            border: 0;
            border-radius: 10px;
            padding: 10px 14px;
            font-weight: 600;
            cursor: pointer;
            background: #0b6bcb;
            color: #fff;
        }
    </style>
</head>
<body>
<main class="card">
    <h2>Redirecting to eSewa...</h2>
    <p class="muted">If this takes too long, use the button below.</p>
    <form id="esewaForm" method="post" action="<%= request.getAttribute("esewaFormUrl") %>">
        <input type="hidden" name="amount" value="<%= request.getAttribute("amount") %>">
        <input type="hidden" name="tax_amount" value="<%= request.getAttribute("taxAmount") %>">
        <input type="hidden" name="total_amount" value="<%= request.getAttribute("totalAmount") %>">
        <input type="hidden" name="transaction_uuid" value="<%= request.getAttribute("transactionUuid") %>">
        <input type="hidden" name="product_code" value="<%= request.getAttribute("productCode") %>">
        <input type="hidden" name="product_service_charge" value="<%= request.getAttribute("serviceCharge") %>">
        <input type="hidden" name="product_delivery_charge" value="<%= request.getAttribute("deliveryCharge") %>">
        <input type="hidden" name="success_url" value="<%= request.getAttribute("successUrl") %>">
        <input type="hidden" name="failure_url" value="<%= request.getAttribute("failureUrl") %>">
        <input type="hidden" name="signed_field_names" value="<%= request.getAttribute("signedFieldNames") %>">
        <input type="hidden" name="signature" value="<%= request.getAttribute("signature") %>">
        <button class="btn" type="submit">Continue to eSewa</button>
    </form>
</main>
<script>
    (function () {
        var form = document.getElementById("esewaForm");
        if (form) {
            form.submit();
        }
    })();
</script>
</body>
</html>
