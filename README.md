# README

## Overview
### Requirements
This project is to satisfy the requirements:

> We’re really happy to invite you to complete the next stage of the engineering
> interview process. For this we’d like you to design a vending machine that behaves
> as follows:
> - Once an item is selected and the appropriate amount of money is inserted,
> the vending machine should return the correct product
> - It should also return change if too much money is provided, or ask for more
> money if insufficient funds have been inserted
> - The machine should take an initial load of products and change. The change
> will be of denominations 1p, 2p, 5p, 10p, 20p, 50p, £1, £2
> - There should be a way of reloading either products or change at a later point
> - The machine should keep track of the products and change that it contains
>
> We’re not monsters, so please don’t take longer than a couple of hours to
> complete this and feel free to let us know if you have any questions.
>
>As well as the functional requirements on the previous slide we also want your solution to:
> - Be written in ruby
> - Have tests
> - Include a readme - think of it like the description you write on a github PR.
> Consider: explaining any decisions you made, telling us how to run it if it’s not
> obvious, signposting the best entry point for reviewing it, etc...
>
> The bulk of our score comes from how you completed these functional and
> non-functional requirements. We also evaluate:
> - How idiomatic your ruby code is
> - The OO design of your classes and methods
> - The simplicity of your solution

### Solution
To satisfy these requirements, I have built a Ruby on Rails API-only application (Rails 6.0.3.3, ruby 2.7.1p83) that exposes
a set of APIs that a client could use to manage the products and denominations contained inside the vending machine, 
as well as a checkouts API to facilitate the payment process.  This application has been deployed to Heroku at
https://enigmatic-citadel-59516.herokuapp.com/ and has been seeded with some sample products and denominations for 
evaluation.

An example flow looks like:

Step 1: Fetch Available Products
```
curl --location --request GET 'https://enigmatic-citadel-59516.herokuapp.com/products'
```
```

```
Step 2: Select a product id to purchase and initiate a checkout. Contained in the response will be information about
```
curl --location --request POST 'https://enigmatic-citadel-59516.herokuapp.com/checkouts/' \
--header 'Content-Type: application/json' \
--data-raw '{ 
    "checkout" : {
        "product_id": "5"
    }
}'
```
```
{
    "id": 1,
    "total_amount": 250,
    "total_amount_payable": 250,
    "status": "requires_payment",
    "total_amount_paid": 0,
    "change": {}
}
```
Step 3: View the available denominations
```
curl --location --request GET 'https://enigmatic-citadel-59516.herokuapp.com/denominations'
```
Step 4: View the available denominations
```
curl --location --request GET 'https://enigmatic-citadel-59516.herokuapp.com/denominations'
```   
Step 5: View the available denominations
```
curl --location --request GET 'https://enigmatic-citadel-59516.herokuapp.com/denominations'
```   

The app is available on Heroku at: https://frozen-coast-18027.herokuapp.com/

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
