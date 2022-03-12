//
//  File.swift
//  
//
//  Created by sawalon.chen on 2022/3/12.
//

import Foundation
import UIKit

private var ExtendEdgeInsetsKey: Void?

extension UIButton {
    /// 设置此属性即可扩大响应范围, 分别对应上左下右
    /// 优势：与Auto-Layout无缝配合
    /// 劣势：View Debugger 查看不到增加的响应区域有多大，
    var extendEdgeInsets: UIEdgeInsets {
        get {
            objc_getAssociatedObject(self, &ExtendEdgeInsetsKey) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(
                self,
                &ExtendEdgeInsetsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if extendEdgeInsets == .zero ||
            !isEnabled ||
            isHidden ||
            alpha < 0.01
        {
            return super.point(
                inside: point,
                with: event
            )
        }
        let newRect = extendRect(bounds, extendEdgeInsets)
        return newRect.contains(point)
    }

    private func extendRect(_ rect: CGRect, _ edgeInsets: UIEdgeInsets) -> CGRect {
        let x = rect.minX - edgeInsets.left
        let y = rect.minY - edgeInsets.top
        let w = rect.width + edgeInsets.left + edgeInsets.right
        let h = rect.height + edgeInsets.top + edgeInsets.bottom
        return CGRect(x: x, y: y, width: w, height: h)
    }
}

// MARK: - 用contentInset的方式增加响应区域（同时增加其frame）

/// 使用示例：
/// button.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 15, right: 18)
/// button.sizeToFit()
/// button.contentCenter = CGPoint(x: button.superview!.frame.maxX - 8 - button.contentFrame.width / 2, y: 100)
/// 注意：使用 frame 和 center 的地方都相应地换成 contentFrame 和 contentCenter，而bounds与frame相对应
///
/// 优势：View Debugger 或 FLEX 看到的 button 大小即为响应区域，所见即所得
/// 劣势：和 Auto-Layout 配合繁琐
extension UIButton {
    var contentFrame: CGRect {
        get {
            frame.inset(by: contentEdgeInsets)
        }

        set {
            frame = newValue.inset(by: contentEdgeInsets)
        }
    }

    var contentCenter: CGPoint {
        get {
            CGPoint(
                x: (frame.minX + contentEdgeInsets.left + frame.maxX - contentEdgeInsets.right) / 2,
                y: (frame.minY + contentEdgeInsets.top + frame.maxY - contentEdgeInsets.bottom) / 2
            )
        }
        set {
            frame.origin = CGPoint(
                x: newValue.x - contentFrame.width / 2 - contentEdgeInsets.left,
                y: newValue.y - contentFrame.height / 2 - contentEdgeInsets.top
            )
        }
    }
}
