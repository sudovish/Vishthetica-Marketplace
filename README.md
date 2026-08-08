# Vishthetica Marketplace

Vishthetica Marketplace is a multi-app iOS marketplace system for buying, selling, reserving, and coordinating second-hand products. The project is structured as a real marketplace ecosystem, not a single screen demo: it includes a customer app, a seller app, backend API integration, and admin/configuration workflows for marketplace operations.

The product focuses on local commerce flows such as product discovery, listing detail pages, cart checkout, seller messaging, pickup/delivery scheduling, trade-in requests, seller inventory tools, order status updates, and admin-managed marketplace configuration.

## Project Summary

This repository is a portfolio snapshot of the Vishthetica marketplace system.

| Area | What it contains |
|---|---|
| Customer App | SwiftUI marketplace app for browsing listings, searching, saving items, cart checkout, contacting sellers, and trade-in flows. |
| Seller App | SwiftUI seller/admin app for login, listings, media upload, orders, schedule, messages, analytics, and admin configuration. |
| Backend/API | App-side API clients and backend handoff documentation for the production API at `https://api-deals.vishthetica.ca`. |
| Admin Panel | Admin role and configuration flows documented through the seller app and backend handoff notes. |

## Why This Project Matters

The marketplace was designed around the full product workflow:

1. A customer discovers a product.
2. The customer reviews specs, price, condition, and seller details.
3. The customer adds the item to cart or contacts the seller.
4. Checkout collects contact, fulfillment, delivery/pickup, and schedule details.
5. The backend creates the order/reservation and keeps seller inventory in sync.
6. The seller sees incoming orders, messages, and schedule commitments.
7. Admin can manage marketplace configuration, seller approval, categories, delivery rules, and operational settings.

That end-to-end thinking is the core of the project: the code is not only UI, it also models the business flow.

## Customer App

The customer app is the buyer-facing marketplace experience.

### Customer Features

- Browse marketplace listings.
- Search listings by title, description, subcategory, and product specs.
- Display products in a polished SwiftUI grid.
- View listing detail pages with specs, condition, location, seller information, and pricing.
- Save/like listings.
- Add listings to a cart.
- Start checkout from cart.
- Collect buyer name, phone, email, address, and fulfillment details.
- Support pickup and delivery-oriented checkout decisions.
- Contact sellers through message, offer, and call-oriented flows.
- Submit trade-in/sell-us-your-device style requests.
- Maintain customer profile and saved marketplace state.

### Customer Code Highlights

Important source areas:

- `CustomerApp/Sources/Models.swift` defines marketplace categories, listings, product specs, user profiles, conditions, and messages.
- `CustomerApp/Sources/AppViewModel.swift` coordinates listing filtering, likes, cart state, checkout state, and seller contact sheets.
- `CustomerApp/Sources/MarketplaceView.swift` renders the searchable marketplace grid and listing selection flow.
- `CustomerApp/Sources/CartModels.swift` defines cart and checkout state.
- `CustomerApp/Sources/TradeInModels.swift` documents the trade-in data model.

## Seller App

The seller app is the operations side of the marketplace. It is built for sellers and admins who manage live listings, communicate with buyers, handle incoming orders, and coordinate fulfillment.

### Seller Features

- Seller login and token-based API session handling.
- Seller dashboard with inventory, order, message, and analytics views.
- Listing creation and editing.
- Listing media upload support.
- Price modes such as firm price, negotiable price, and price range.
- Seller order list and order detail flows.
- Order state updates such as confirm, ready, on the way, pickup, delivered, cancelled, and completed.
- Buyer/seller messaging.
- Seller schedule preferences for pickup and delivery windows.
- Admin role support for configuration and marketplace controls.
- Analytics-oriented views for sales, listing performance, and marketplace activity.

### Seller Code Highlights

Important source areas:

- `SellerApp/Sources/SellerAPI.swift` shows the live backend integration pattern, including auth, health checks, listings, orders, conversations, schedules, media upload, and order status updates.
- `SellerApp/Sources/SellerModels.swift` defines seller listings, specs, price modes, orders, delivery windows, messages, seller profiles, and admin status.
- `SellerApp/Sources/SellerViewModel.swift` documents how the seller UI coordinates API state, optimistic UI state, login/session flow, listings, orders, and messages.

## Backend And Admin

The production backend used by the app is referenced by the app-side API client:

```text
https://api-deals.vishthetica.ca
```

The mounted workspace used for this repository included the iOS app source and backend handoff/audit documents. The complete backend server source and database migrations were not mounted locally, so this repo includes backend/API documentation and app-side integration code rather than claiming a full backend source dump.

### Backend Responsibilities

The backend is designed as the shared source of truth for:

- customer, seller, and admin roles
- seller applications and approval state
- listings and inventory visibility
- product categories and required specs
- cart checkout/order reservation
- pickup and delivery coordination
- buyer/seller conversations
- trade-in request intake
- admin-managed marketplace configuration
- analytics and operational reporting
- media storage and listing assets

### Admin Panel / Admin Role

The admin workflow is modeled as an elevated seller role. Admin users can perform seller actions and also manage platform-level configuration.

Admin responsibilities include:

- approve or reject seller applications
- supervise seller listings
- manage categories and spec requirements
- manage delivery/location pricing rules
- manage trade-in pricing/configuration
- publish app configuration changes
- inspect marketplace health, orders, listings, messages, and analytics

## Architecture

The system is split into three layers:

```text
Customer iOS App
    -> browses public marketplace data
    -> starts checkout, messages, and trade-in flows

Seller/Admin iOS App
    -> authenticated seller/admin operations
    -> listings, media, orders, messages, schedule, analytics

Backend API
    -> production API and database source of truth
    -> inventory, roles, orders, conversations, config, and admin controls
```

## Repository Layout

```text
.
├── README.md
├── CustomerApp/
│   └── Sources/
│       ├── AppViewModel.swift
│       ├── CartModels.swift
│       ├── MarketplaceView.swift
│       ├── Models.swift
│       └── TradeInModels.swift
├── SellerApp/
│   └── Sources/
│       ├── SellerAPI.swift
│       ├── SellerModels.swift
│       └── SellerViewModel.swift
└── docs/
    ├── backend/
    │   └── HANDOFF.md
    └── audit/
        └── PHASE_1_AUDIT_SUMMARY.md
```

## Tech Stack

- Swift
- SwiftUI
- Foundation
- Combine
- URLSession
- Codable API DTOs
- Async/await networking
- Live REST API integration
- Token-based seller authentication
- GitHub portfolio documentation

## Build Notes

The local workspace contains Xcode project files for the customer and seller apps. In a full local checkout, each app can be opened independently in Xcode:

```text
CustomerApp/CustomerApp.xcodeproj
SellerApp/SellerApp.xcodeproj
```

For this GitHub portfolio snapshot, the focus is on readable source and system design rather than including private build artifacts, simulator files, `.xcuserdata`, credentials, secrets, or generated state.

## Security And Privacy Notes

This repository intentionally excludes:

- API secrets
- private credentials
- local Xcode user state
- database dumps
- generated build outputs
- production environment variables

The backend docs also call out areas that should be hardened before public launch, including customer authentication, idempotent order creation, authorization checks, receipt/PDF generation, testing, and payment confirmation state.

## Current Status

This project is suitable as a portfolio/case-study repo showing the product architecture, iOS app structure, marketplace flows, and backend integration design.

The production-readiness audit found that the app shells and several API integrations are real, but more backend source verification, testing, receipt generation, customer auth hardening, and operational controls are required before a full public launch.
