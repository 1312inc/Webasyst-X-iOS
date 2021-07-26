//
//  BlogDetail module - BlogDetailViewModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: BlogDetailViewModel
protocol BlogDetailViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: BlogDetailViewModel
final class BlogDetailViewModel: BlogDetailViewModelType {
    
    struct Input {
       //...
    }
    
    let input: Input
    
    struct Output {
        var postData: BehaviorSubject<PostList>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
            
    //MARK: Input Objects
    
    //MARK: Output Objects
    private var postDataSubject = BehaviorSubject<PostList>(value: PostList(id: "", blog_id: "", datetime: "", title: "", text: "", comment_count: 0, icon: "", user: nil))

    init(post: PostList) {
        //Init input property
        self.input = Input(
            //...
        )

        //Init output property
        self.output = Output(
            postData: postDataSubject.asObserver()
        )
        
        self.postDataSubject.onNext(post)
    }
    
}
