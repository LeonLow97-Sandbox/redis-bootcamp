## Project 1: E-Commerce App Setup (`rbay`)

- Add redis connection to `.env` file
- Start up application `npm run dev`

```js
// ~/rbay/src/services/queries/page-cache.ts
const cacheRoutes = ['/about', '/privacy', '/auth/signin', 'auth/signup'];

export const getCachedPage = (route: string) => {
  if (cacheRoutes.includes(route)) {
    return client.get(pageCacheKey(route));
  }
  return null;
};

export const setCachedPage = (route: string, page: string) => {
  if (cacheRoutes.includes(route)) {
    return client.set(pageCacheKey(route), page, {
      EX: 2, // might still have updates to these static pages
    });
  }
};
```

## App Overview

- Deep walkthrough of the ecommerce app
- Do design work on how we are going to store data in Redis.
- Figure out what data should be stored as hashes.

## Basic Auction Rules

- Users create 'items' to sell.
- Items have a starting price and an ending time.
- Other users can 'bid' on an item. A bid must be higher than all previous bids.
- At the ending time, the user with highest bid wins the item.

---

#### Reasons to Store as Hash (users, sessions, items)

- The record has many attributes
- A collection of these records have to be sorted many different ways
- Often need to access a **single record** at a time, e.g. users, don't have a case where you need to fetch all the users

---

#### Don't use Hashes when... (bids, likes, views)

- The record is only for counting or enforcing uniqueness, e.g., a user can only like a product once
- Record stores only one or two attributes
- Used only for creating relations between different records
- The record is only used for time series data. e.g., snapshot of 1 or 2 values that are changing over time

---

# Implementations

### `CreateUser`

```
users#I3j5I23 : {
	username : leonlow97
	password: password123
}
```