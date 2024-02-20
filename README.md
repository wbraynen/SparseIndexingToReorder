#  A demo of sparse indexing of CoreData records

## The goal of this demo

The goal of this demo is to make the reordering of CoreData records more performant.  The solution demoed here is parse indexing.  (The periodic background re-indexing is out of scope.)

Also, I wanted to play around with CoreData in the context of SwiftUI (but without `SwiftData`).

## Results

Moving an item given 100,000 records does not eat up all the RAM on my device and is more performant on my device and sim.

Also, interestingly, SwiftUI's `@FetchRequest` has no trouble displaying the records quickly no matter the size of the database and that scrolling is smooth.  So, although not the decoupled architecture I am used to from UIKit, seems to be optimized out of the box.

## Out of scope

Illustrating the use of view models or paging was not the goal of this demo.  So, those elements are entirely missing from this code.  Optimizing to not have the UIGestureRecognizer time out or performing a bunch of moves in a row quickly is similarly out of scope.  However, observe that with SwiftUI, interestily, this code is already more performant out of the box than I would have expected!


## The code and commit history

Look at the `seedWithSampleData` and `moveItems` functions.  They are the most interesting.

```
private func seedDataUsingBackgroundContext() {
  // create 100,000 records and set the orderIndexes to [1000, 2000, 3000, ...] instead of [1,2,3,...] (or, similarly, [0,1,2,...]).
}
```
and
```
/// `Int64` because of our database model.  Otherwise I would have just used the `Int` type.
private func calculateNewIndex(forDestinationIndex destinationIndex: Int) -> Int64 {
    let newIndex: Int64

    if destinationIndex < 0 {
        // first items's index / 2
        newIndex = calculateIndexForTopPosition()
    } else if destinationIndex >= items.count - 1 {
        // last item's index + 1000
        newIndex = calculateIndexForBottomPosition()
    } else {
        // squeeze this in between the before and after items
        newIndex = calculateIndexForMiddlePosition(at: destinationIndex)
    }

    return newIndex
}
```

Look at the git log to see both the problem, the one with this commit title: "👀 Increased the number of records to 100,000 to illustrate the problem".  (The initial commit is just Xcode's boilerplate.)

