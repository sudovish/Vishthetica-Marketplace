# Backend Handoff

This document summarizes the backend design for the Vishthetica marketplace system.

## Connected Apps

The backend supports four product surfaces:

- Customer iOS app
- Seller iOS app
- Admin tab inside the seller app
- Future web admin dashboard

The production API used by the mounted app source is:

```text
https://api-deals.vishthetica.ca
```

## Platform Roles

### Guest Customer

Can browse listings, search the marketplace, view listing details, start checkout, and begin a trade-in estimate. Identity is collected when a flow requires it, such as checkout, messaging, or trade-in continuation.

### Customer Account

Intended capabilities include ordering, messaging, active order history, past order history, trade-in history, and notification preferences.

### Pending Seller

Can sign into the seller app and view pending approval state. Cannot publish listings or interact with buyers until approved.

### Approved Seller

Can create listings, upload media, manage inventory, view seller analytics, coordinate pickup/delivery, respond to buyer messages, and update order status.

### Admin Seller

Can do everything an approved seller can do, plus platform-level operations such as seller approval, category/spec management, delivery pricing configuration, trade-in pricing configuration, marketplace visibility controls, and published app configuration.

## Backend Responsibilities

The backend is the shared source of truth for:

- users and roles
- seller profiles and seller applications
- listing status and inventory availability
- product categories and subcategories
- required listing specs by category
- order reservations and checkout records
- pickup/delivery windows
- buyer/seller conversations
- trade-in request intake and estimate configuration
- admin app configuration drafts and published versions
- media storage
- analytics
- operational audit events

## Core Data Models

### users

```json
{
  "id": "uuid",
  "role": "customer | seller | admin",
  "email": "string nullable",
  "phone": "string",
  "displayName": "string",
  "createdAt": "datetime",
  "lastActiveAt": "datetime",
  "pushToken": "string nullable",
  "status": "active | disabled"
}
```

### seller_profiles

```json
{
  "id": "uuid",
  "userId": "uuid",
  "storeName": "string",
  "phone": "string",
  "location": "string",
  "productsSold": ["string"],
  "approvalStatus": "pending | approved | rejected | suspended",
  "approvedAt": "datetime nullable",
  "approvedByAdminId": "uuid nullable",
  "rating": 0
}
```

### listings

```json
{
  "id": "uuid",
  "sellerId": "uuid",
  "title": "string",
  "description": "string",
  "categoryId": "uuid",
  "subcategoryId": "uuid nullable",
  "price": 1449,
  "discountPrice": 1299,
  "currency": "CAD",
  "quantityTotal": 1,
  "quantityAvailable": 1,
  "quantityReserved": 0,
  "condition": "new | like_new | good | fair | parts",
  "specs": {
    "storage": "256GB",
    "batteryHealth": "88",
    "carrierLock": "Unlocked"
  },
  "locationLabel": "Yonge & Bloor",
  "city": "Toronto, ON",
  "status": "draft | live | reserved | sold | paused | archived",
  "customerVisible": true,
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### orders

Orders should snapshot price, listing details, seller, buyer contact details, selected fulfillment type, delivery fee, schedule window, payment method, and status transitions. Inventory reservation needs to be transactional so one-of-one products cannot be double sold.

### conversations

Conversations connect buyers, sellers, listings, and orders. Messages should support authorization, unread counts, audit trails, and future push/email notification events.

### app_config

Published app configuration should drive customer-facing categories, spec requirements, trade-in pricing, delivery rules, and feature visibility.

## Important API Areas

The seller app API client references routes for:

- `GET /health`
- `GET /version`
- `POST /auth/login`
- `POST /auth/refresh`
- `GET /me`
- `GET /seller/listings`
- `GET /seller/orders`
- `GET /conversations`
- `GET /conversations/{id}/messages`
- `POST /conversations/{id}/messages`
- `POST /conversations/{id}/read`
- `GET /seller/schedule`
- `PATCH /seller/schedule`
- `POST /seller/orders/{id}/accept`
- `POST /seller/orders/{id}/status`

## Launch Hardening Checklist

Before a full public launch, the backend should have:

- idempotent order creation
- transactional inventory reservation
- customer authentication or hardened guest claim tokens
- strict role-based authorization
- input validation and media upload rules
- receipt/PDF generation
- receipt email/retry tracking
- immutable order timeline events
- notification delivery records
- database migrations and backup/restore documentation
- unit, integration, and end-to-end tests
