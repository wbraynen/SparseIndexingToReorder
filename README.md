#  A demo of parse indexing of CoreData records

## There is no view model and no paging

Illustrating the use of view models or paging was not the goal of this demo.  So, those elements are entirely missing from this code.

Also, interestingly, note that SwiftUI's `@FetchRequest` has no trouble displaying the records quickly no matter the size of the database and that scrolling is smooth.  So, although not the decoupled architecture I am used to from UIKit, seems to be optimized out of the box.


## The goal of this demo

Reordering CoreData records in a reasonable amount of time no matter how big the dataset persisted to disk.  The solution demoed here is parse indexing.

Not production ready 🫠, but interesting 😃.


## Results

With the problem, the UI will freeze given 100,000 records, let alone a million.  With the solution (e.g. tip of the `main` branch), on my physical phone, it takes about 6 seconds to reorder whether the dataset is 10 records or 10 million records.  6 seconds for 10 records is bad (so a view model would be helpful), but 6 seconds still for 10 million records is great.


## The code and commit history

Look at the `seedWithSampleData` and `moveItems` functions.

Look at the git log to see both the problem and, in a later commit, the solution.  (The initial commit is just Xcode's boilerplate.)
