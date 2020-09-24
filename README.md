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

*Step 1:* Fetch Available Products
```
curl --location --request GET 'https://enigmatic-citadel-59516.herokuapp.com/products'
```
```
[
    ...
    {
        "id": 4,
        "name": "Vodka",
        "quantity": 10,
        "available": true,
        "price_pence": 44
    },
    {
        "id": 5,
        "name": "Cat",
        "quantity": 10,
        "available": true,
        "price_pence": 250
    }
]
```
*Step 2:* Select a product id to purchase and initiate a checkout. Contained in the response will be information about
how much money is due, how much has been paid, and the current state of the checkout
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
*Step 3:* View the available denominations
```
curl --location --request GET 'https://enigmatic-citadel-59516.herokuapp.com/denominations'
```
```
[
    {
        "id": 9,
        "value": 1,
        "quantity": 100
    },
    ...
    {
        "id": 16,
        "value": 200,
        "quantity": 100
    }
]
```
*Step 4:* Choose a denomination and use it to pay for the checkout. The response will tell you how much money is still due
and how much has been paid up to this point.
```
curl --location --request PATCH 'https://enigmatic-citadel-59516.herokuapp.com/checkouts/1' \
--header 'Content-Type: application/json' \
--data-raw '{ 
    "checkout" : {
    "denomination_id": "16"
}}'
```   
```
{
    "id": 1,
    "total_amount": 250,
    "total_amount_payable": 50,
    "status": "requires_payment",
    "total_amount_paid": 200,
    "change": {}
}
```
*Step 5:* Continue to update the checkout until you have fully paid for the product, at which the response
will tell you how much change has been returned to the customer. Internally the coins used for change and the product
will have been debited from our inventory.
```
curl --location --request GET 'https://enigmatic-citadel-59516.herokuapp.com/denominations'
```   
```
{
    "id": 1,
    "total_amount": 250,
    "total_amount_payable": 0,
    "status": "succeeded",
    "total_amount_paid": 400,
    "change": {
        "total_amount": 150,
        "coin_count": 2,
        "denominations": [
            {
                "100": 1
            },
            {
                "50": 1
            }
        ]
    }
}
```

When we are unable to make change for a checkout, the current behavior is that we refund the customer and return an error
message with 503 status code telling them to try again later or with different denominations.

To manage the inventories of the products or denominations in the vending machine, you would simply use the basic CRUD
endpoints available for those resources.

### Project Structure
As everything is driven by the API interactions and there is no background processing, I recommend starting a review
at the controllers for the 3 primary resources: `Products`, `Denominations`, and `Checkouts`.

The meat of the service revolves around the checkout process. Some key classes responsible for facilitating the 
checkout flow outside of the CheckoutsController are:
- app/commands/change_calculator.rb - Responsible for calculating change based on available coins in the system
- app/commands/change_processor.rb - Facilitates the calculation of required change and then the debiting of the change from the system 

As change calculation can be computationally intensive depending on your approach, I used a dp algorithm with a 
time complexity of O(dt) where d = total number of denominations available and t = the total change required.

### Other Considerations/Comments/Thoughts/Future Work
#### Testing
While my checkout request specs did a good job of doing end to end tests exercising complete code paths, I wasn't able 
to fully test the app in the manner I would for a production release due to time constraints. Some of
the tests I would continue to add given the time are:
- test more of the validations cases at the beginning of checkout request spec
- tests for serializers
- Request specs for the basic CRUD functionality in the Product and Denomination APIs.
- BDD/Cucumber style testing that simulates the series of API calls 
- More complete coverage on models
#### Error Handling
Some additional work needed on the error handling front are:
- Error messages need to be driven by translations instead of raw text
- Error responses should have additional details in them like error_code and error_details
- When we cannot make change, we currently return an error and 503 while also fully refunding the customer. This
may not be the best way to handle this error case and we would need to discuss further.


## Dependencies
[gorails](https://gorails.com/setup/) has a great up to date setup guide, which covers a number of the remaining dependencies listed below:

* (On Mac only) Inst all Xcode tools: `xcode-select --install`
* [Homebrew](https://brew.sh/)
* [RVM](https://github.com/rvm/rvm) my preferred tool for ruby version management, but you can also use rbenv.
* [Ruby](https://www.ruby-lang.org/en/). This project was developed using one of the more recent stable versions of Ruby
* [Bundler](https://bundler.io/) which is used to manage gem dependencies: `gem install bundler`
* [Ruby on Rails](https://rubyonrails.org/) - Using Rails version 6,0,3 and Ruby version 2.7.1
* [Postgresql](https://www.postgresql.org/) - Used for database storage 

## Build and Run
* Clone the repository locally into your preferred directory: `git clone https://github.com/prangarang/vending_machine.git`
* cd into project `cd vending_machine`
* install gem dependencies: `bundle install`
* Create DB/DB Schema and seed the database with initial test data: `bundle exec rake db:create db:migrate db:seed`
* Start the rails server: `bin/rails server`

### Automated Testing
To run the tests locally, you run: `bundle exec rspec spec`.

### Deployment
The app is currently deployed on Heroku at https://enigmatic-citadel-59516.herokuapp.com/products

To Deploy push the `master` branch up to the heroku remote: `git push heroku master`

If the deployment contains migrations, then you will need to run `heroku run db:migrate`

If you are seeding the database for the first time run `heroku run db:seed`