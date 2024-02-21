#  A POC: a demo of sparse indexing of CoreData records

👻 This is a POC.

<img src="https://github.com/wbraynen/SparseIndexingToReorder/assets/4765449/5faabc3a-bf15-4004-9fe2-0a12d6bec017" width=250>
<img src="https://github.com/wbraynen/SparseIndexingToReorder/assets/4765449/738603d0-e84b-4694-b1ea-bc31e4cd80c6" width=250>

## The goal of this demo

The goal of this demo is to make the reordering of CoreData records more performant, so that it can handle reordering just as quickly when you have 100,000 records as when you have only a few hundred.  The solution demoed here is sparse indexing.  "Sparse indexing" is a technical term in databases and not necessarily what I mean in this POC.  What I mean by "sparse indexing" is the indexing of _all_ records (not just some), but where the indexing is not `[1,2,3,4,...,totalNumberOfRecords]`, but instead `[1000,2000,3000,4000,...,totalNumberOfRecords * 1000]`.  So maybe I should have called it "spaced indexing" instead.

Also, I wanted to play around with CoreData in the context of SwiftUI (but without SwiftData).

The periodic background re-indexing is out of scope. But also note that having to periodically re-index is much better than having to re-index each and every time the user moves an item, which is what you would have to do with the typical solution where the `orderIndex` is not sparse.

And yes, this is a bit like in the Basic programming language execution lines would be numbered, conventionally, as 10,20,30,..., so that it would be easy to later insert lines 😅.


## Results

Moving an item given 100,000 records does not eat up all the RAM on my device and is more performant on my device and sim.

Also, interestingly, SwiftUI's `@FetchRequest` has no trouble displaying the records quickly no matter the size of the database and that scrolling is smooth.  So, although not the decoupled architecture I am used to from UIKit, seems to be optimized out of the box.

Not production ready 🫠 because it's a POC 👻, but interesting 🤓.

## Out of scope

1. Implementing the periodic re-indexing after N moves that should take place on some background thread.
2. Illustrating the use of view models.
3. Illustrating the use of paging.
4. Fixing the `UIGestureRecognizer` warning bug, although would be nice to fix it. Ping me (or raise a PR) if you know what's wrong if I don't find time to look at it.

Re. 2 and 3: Observe that with SwiftUI, interestily, this code is already more performant out of the box than I would have expected))

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

# Known issues

When, as a user, you move items around, after ten moves or so, you'll get the following warning in the Xcode console:
```
<0x15300bc10> Gesture: System gesture gate timed out.
```
