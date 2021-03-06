//  InAppActionViewController+ThreadActions.swift
//
//  Copyright 2015 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

import AwfulCore
import UIKit

extension InAppActionViewController {
    convenience init(thread: Thread, presentingViewController viewController: UIViewController) {
        self.init()
        
        var items = [AwfulIconActionItem]()
        
        func jumpToPageItem(itemType: AwfulIconActionItemType) -> AwfulIconActionItem {
            return AwfulIconActionItem(type: itemType) {
                let postsViewController = PostsPageViewController(thread: thread)
                postsViewController.restorationIdentifier = "Posts"
                let page = itemType == .JumpToLastPage ? AwfulThreadPage.Last.rawValue : 1
                postsViewController.loadPage(page, updatingCache: true, updatingLastReadPost: true)
                viewController.showDetailViewController(postsViewController, sender: self)
            }
        }
        items.append(jumpToPageItem(.JumpToFirstPage))
        items.append(jumpToPageItem(.JumpToLastPage))
        
        let bookmarkItemType: AwfulIconActionItemType = thread.bookmarked ? .RemoveBookmark : .AddBookmark
        items.append(AwfulIconActionItem(type: bookmarkItemType) { [weak viewController] in
            AwfulForumsClient.sharedClient().setThread(thread, isBookmarked: !thread.bookmarked) { error in
                if let error = error {
                    let alert = UIAlertController(networkError: error, handler: nil)
                    viewController?.presentViewController(alert, animated: true, completion: nil)
                }
            }
            return // hooray for implicit return
            })
        
        if let author = thread.author {
            items.append(AwfulIconActionItem(type: .UserProfile) {
                let profile = ProfileViewController(user: author)
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    viewController.presentViewController(profile.enclosingNavigationController, animated: true, completion: nil)
                } else {
                    viewController.navigationController?.pushViewController(profile, animated: true)
                }
                })
        }
        
        items.append(AwfulIconActionItem(type: .CopyURL) {
            if let URL = NSURL(string: "https://forums.somethingawful.com/showthread.php?threadid=\(thread.threadID)") {
                AwfulSettings.sharedSettings().lastOfferedPasteboardURL = URL.absoluteString
                UIPasteboard.generalPasteboard().awful_URL = URL
            }
            })
        
        if thread.beenSeen {
            items.append(AwfulIconActionItem(type: .MarkAsUnread) { [weak viewController] in
                let oldSeen = thread.seenPosts
                thread.seenPosts = 0
                AwfulForumsClient.sharedClient().markThreadUnread(thread) { error in
                    if let error = error {
                        if thread.seenPosts == 0 {
                            thread.seenPosts = oldSeen
                        }
                        let alert = UIAlertController(networkError: error, handler: nil)
                        viewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                })
        }
        
        self.items = items
    }
}
