paschedules
===

### Set Up Guide

In order to set up paschedules on your machine, perform the following:

1. First clone the project using `git clone`.
2. Go to the directory and `bundle install`.
3. Create a file `login_info` in the `root` directory, and in the first line insert your PANet username, and in the second line add your password.  This file is in `.gitignore`, so don't worry.
4. Then do `mv config/database.sample.yml config/database.yml`, and open the YAML file.  In the file replace `USERNAME` with your local account's username.
5. Open a new shell and start `postgresql`.
6. To create the database, do `rake db:create`.
7. Then, after all of the gems have been installed, `rails s`.  If you get an error, and can't fix it open an [issue](https://github.com/ruddfawcett/paschedules/issues).
8. Sign up on the site as you would (the users are only on the Heroku server), and login.

### Parsing Guide

1. Create a Firefox profile named `schedules`.  Use the Firefox CLI tool -- `./firefox -P`.
2. Next, you need to run the parser.  Firefox should open -- that's OK.  The first step is to parse the directory, so `rake schedules:parseDirectory`.  If you get any errors, it's because the website has changed, open an [issue](https://github.com/ruddfawcett/paschedules/issues) if I'm still at school.  Otherwise, try to figure it out.
3. After you have parsed the directory, make a backup: `ruby scheduleDump.rb FILENAME`.  I like to have the file be a ZIP, but it doesn't have to be.
4. Then, parse the user IDs from the schedule search.  Again, if you get an error the schedule has changed, `rake schedules:parseIds`.  
5. Make another backup.
6. Use `rake schedules:purgeNilIds` to get rid of people no longer in PANet.  I would also use `rails c` to get rid of last year's seniors (assuming you're doing this in the fall). `Student.where(grad_year: "GRAD YEAR").destroy_all`.
7. Then, finally, we're going to parse the schedules.  If you get an error, the site has changed, `rake schedules:parseSchedules`.
8. If you get a teacher error, then you need to use `Teacher.create()` in `addExceptions` don't keep running that task though, it will add multiple teachers with the same name.  Use `rails c`, and copy a `Teacher.create()` line manually.
9. Then, run the other tasks, `rake schedules:purgeBlankSchedules`,`rake schedules:convertToCommitments`, and `rake schedules:updateUserCounter`.
10. Make a backup, and then start the server.  Login with the user you created, and enjoy.


### Credits

Originally created by Jake Herman '15 and Jamie Bloxham '15 in January 2014, as part of a Computer Science class at Phillips Andover.

The project was taken over in August 2015 by Rudd Fawcett as Jake and Jamie graduated.
