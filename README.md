
## SOLVED

### Decrement button:

Feature tests were first up here. 

Added a test to expect a Decrement button on the home page. In a separate file I added the tests that made sure the Decrement button did what was expected.

This was a simple reverse of the Increment button. The code was the same, just simply switching the updated read_count to -1 rather than +1

``` ruby
#in counter.rb
def decrement
    read_count = count
    result = DatabaseConnection.query("UPDATE counter SET count = '#{read_count - 1}' WHERE id=1;")
  end
```
```ruby
#in app.rb
post '/decrement' do
    @counter.decrement
    redirect '/'
  end
```
```ruby
#in index.erb
<div id="count"><%= @counter.count %></div>
    <form action="/decrement" method="post">
      <input type="submit" value="Decrement">
    </form>
```

### Time since last click:
Adding time locally was fine, but adding it to the database so that it would be stored between boot ups was a little bit more complicated.

First thing was to alter the table, in psql, to add a column 'lastmodified' using time stamp.

``` sql 
ALTER TABLE counter
	ADD lastmodified TIMESTAMP;
```
Then I had to alter the new column to set a default of current time AND then set that. These are two steps

``` sql
#first setting what the default is
ALTER TABLE counter
	ALTER COLUMN lastmodified
		SET DEFAULT CURRENT_TIMESTAMP;
#now we have to set it
UPDATE counter
	SET lastmodified=CURRENT_TIMESTAMP;
```

This sets the current time but there's nothing in place to tell it when to update. Next step is to create a function in psql.

```sql
CREATE OR REPLACE FUNCTION update_lastmodified_column()
	RETURNS TRIGGER AS '
 BEGIN
	NEW.lastmodified = NOW();
	RETURN NEW;
 END;
' LANGUAGE 'plpgsql';
```
Finally, the last step is to create a trigger to make this function work automatically.

```sql
CREATE TRIGGER update_lastmodified_modtime BEFORE UPDATE
 ON counter FOR EACH ROW EXECUTE PROCEDURE
 update_lastmodified_column();
```

This is implement in my code as below:

```ruby
#in counter.rb
def time
    result = DatabaseConnection.query('SELECT * FROM counter WHERE id=1;')
    result[0]['lastmodified'].to_s
  end
```

```ruby
#in index.erb
<div id="counter_time">Counter last pressed at:<%= @counter.time %></div>
```


See below for challenge.


# Description
This is a counter web app built in Ruby using Sinatra and Capybara. This app uses PostgreSQL to store the count.

# Setting up the database
1. Connect to `psql`
2. Create the production and test databases using the psql commands `CREATE DATABASE count_manager;` and `CREATE DATABASE count_manager_test;`
3. Connect to the production database using the pqsl command `\c count_manager;`
4. Run the queries saved in the file `01_create_counter_table.sql`
5. Repeat steps 3 and 4 for the test database.

# How to run the app
1. Clone this repository
2. `cd` into the cloned directory
3. Run `bundle` to install dependencies
4. Run `rackup`
5. Navigate to `http://localhost:9292/` in your browser

# How to run the tests
1. Clone this repository
2. `cd` into the cloned directory
3. Run `bundle` to install dependencies
4. Run `rspec`

# Questions to explore
* What is the difference in behaviour between this app and one which there is [no database](https://github.com/tatsiana-makers/count-sinatra)?
* Which of the MVC components interacts with the database?
* What parts of the code run when we run the app in our browser? You could test your assumption by adding `p` lines and checking that you see the output you expect.
* What part of the code runs when we click the "Increment" button?
* Can you add a "Decrement" button which decreases the count by 1 each time it is pressed?
* Can you update the app to display the time that the count was last updated? This value should be stored in the database so that it will be accurately displayed even if the server is restarted.
