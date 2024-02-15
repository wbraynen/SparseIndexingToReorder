#  A demo of sparse indexing of CoreData records

## There is no view model and no paging

Illustrating the use of view models or paging was not the goal of this demo.  So, those elements are entirely missing from this code.

Also, interestingly, note that SwiftUI's `@FetchRequest` has no trouble displaying the records quickly no matter the size of the database and that scrolling is smooth.  So, although not the decoupled architecture I am used to from UIKit, seems to be optimized out of the box.


## The goal of this demo

The goal of this demo is reordering CoreData records in a reasonable amount of time no matter how big the dataset persisted to disk.  The solution demoed here is parse indexing.  (The periodic background re-indexing is out of scope.)


## Results

⚠️ Please be patient: it takes a little while to seed the database with 100,000 records the very first time you run this demo.

Big Oh: Constant time instead of linear time.  That is, it takes the same amount of time (and not very long at all) to move one record to another spot no matter the size of the dataset.  This avoids having the UI freeze up given 100,000 records.

Not production ready 🫠, but interesting 😃.


## The code and commit history

Look at the `seedWithSampleData` and `moveItems` functions.

Look at the git log to see both the problem and, in a later commit, the solution.  (The initial commit is just Xcode's boilerplate.)
