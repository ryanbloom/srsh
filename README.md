# `srsh`: Spaced Repetition for Shell Commands

`srsh` is a simple program designed to help you learn shell commands.

## Installation

First, make sure you have [Crystal](https://crystal-lang.org) installed.
Then:

```bash
git clone https://github.com/ryanbloom/srsh.git
cd srsh
shards install
crystal build src/main.cr -o srsh
```

You'll probably want to move the output to a directory that's included
in your `$PATH`.

## Getting started

First, create a text file with some examples of the commands
you want to learn. 

```
# Navigation

123
List the files in the current directory, including hidden files.
ls -a
```

Here, `123` is a unique ID for the exercise. You can leave it out, but
then any modification will be imported as a new exercise instead of a 
replacement for the old one. Exercises will be presented with the most
recent heading (denoted with `#`) to provide context.

To import a file, use `srsh import exercises.txt`. This will read in all the
exercises and put them into a SQLite database at `~/srsh.db`. You can change
the location of the database with the environment variable `$SRSH_DB`.

## Review

`srsh` automatically schedules exercises for review at increasing intervals.
To start a review session, simply run `srsh`.

To delete an exercise, type `!del` when prompted for the answer.
