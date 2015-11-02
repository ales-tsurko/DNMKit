// SimpleRoot.swift - As straight a port as I could get my head around of Jim Armstrong's
// port of Jack Crenshaw's TWBRF simple root finding algorithm. See license below:
//
// SimpleRoot.as - A straight port of Jack Crenshaw's TWBRF method for simple roots in an interval.  To use, identify an interval in which
// the function whose zero is desired has a sign change (via bisection, for example).  Call the findRoot method.
//
// This program is derived from source bearing the following copyright notice,
//
// Copyright (c) 2008, Jim Armstrong.  All rights reserved.
//
// This software program is supplied 'as is' without any warranty, express,
// implied, or otherwise, including without limitation all warranties of
// merchantability or fitness for a particular purpose.  Jim Armstrong shall not
// be liable for any special incidental, or consequential damages, including,
// witout limitation, lost revenues, lost profits, or loss of prospective
// economic advantage, resulting from the use or misuse of this software program.
//
// Programmed by Jim Armstrong, (http://algorithmist.wordpress.com)
// Ported to Degrafa with full permission of author
/**
* @version 1.0
*/
import QuartzCore

public class SimpleRoot {
    
    private var i: Int = 0
    
    public init() { }
    
    public func findRoot(
        x0 x0: CGFloat,
        x2: CGFloat,
        maximumIterationLimit: Int,
        tolerance: CGFloat,
        f: CGFloat -> CGFloat
    ) -> CGFloat
    {
        var xmLast: CGFloat = x0
        var y0: CGFloat = f(x0)
        if y0 == 0.0 { return x0 }
        
        var y2 = f(x2)
        if y2 == 0.0 { return x2 }
        if y2 * y0 > 0.0 { return x0 }
        
        var x0 = x0
        var x2 = x2
        var x1: CGFloat = 0
        var y1: CGFloat = 0
        var xm: CGFloat = 0
        var ym: CGFloat = 0
        
        while i <= maximumIterationLimit {

            // increment
            i++
            
            x1 = 0.5 * (x2 + x0)
            y1 = f(x1)
            if y1 == 0 { return x1 }
            
            if abs(x1 - x0) < tolerance { return x1 }
            
            if y1 * y0 > 0 {
                var temp = x0
                x0 = x2
                x2 = temp
                temp = y0
                y0 = y2
                y2 = temp
            }
            
            let y10 = y1 - y0
            let y21 = y2 - y1
            let y20 = y2 - y0
            
            if (y2 * y20 < 2 * y1 * y0) {
                x2 = x1
                y2 = y1
            }
            else {
                let b = (x1 - x0) / y10
                let c = (y10 - y21) / (y21 * y20)
                xm = x0 - b * y0 * (1 - c * y1)
                ym = f(xm)
                if ym == 0 { return xm }
                if abs(xm - xmLast) < tolerance { return xm }
                xmLast = xm
                if ym * y0 < 0 {
                    x2 = xm
                    y2 = ym
                }
                else {
                    x0 = xm
                    y0 = ym
                    x2 = x1
                    y2 = y1
                }
            }
        }
        return x1
    }
}

