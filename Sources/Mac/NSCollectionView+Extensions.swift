//
// NSCollectionView+DeepDiff
//  Notability
//
//  Created by Kyle Rokita on 10/23/18.
//  Copyright © 2018 Ginger Labs. All rights reserved.
//

import AppKit

@available(OSX 10.11, *)
public extension NSCollectionView {
    
    /// Animate reload in a batch update
    ///
    /// - Parameters:
    ///   - changes: The changes from diff
    ///   - section: The section that all calculated IndexPath belong
    ///   - completion: Called when operation completes
    public func reload<T: Hashable>(
        changes: [Change<T>],
        section: Int = 0,
        completion: ((Bool) -> Void)? = nil) {
        
        let changesWithIndexPath = IndexPathConverter().convert(changes: changes, section: section)
        
        // reloadRows needs to be called outside the batch
        
        performBatchUpdates({
            internalBatchUpdates(changesWithIndexPath: changesWithIndexPath)
        }, completionHandler: { finished in
            completion?(finished)
        })
        
        changesWithIndexPath.replaces.executeIfPresent {
            self.reloadItems(at: Set($0))
        }
    }
    
    // MARK: - Helper
    
    private func internalBatchUpdates(changesWithIndexPath: ChangeWithIndexPath) {
        NSAnimationContext.current.duration = 1.0;

        changesWithIndexPath.deletes.executeIfPresent {
            animator().deleteItems(at: Set($0))
        }
        
        changesWithIndexPath.inserts.executeIfPresent {
            animator().insertItems(at: Set($0))
        }
        
        changesWithIndexPath.moves.executeIfPresent {
            $0.forEach { move in
                animator().moveItem(at: move.from, to: move.to)
            }
        }
    }
}

