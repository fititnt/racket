#lang scribble/doc 
@(require "mz.rkt" (for-label racket/future/trace racket/future)) 

@title[#:tag "futures-visualizer"]{Futures Visualizer} 

@guideintro["effective-futures"]{the future visualizer}

@defmodule[racket/future/visualizer] 

The @deftech{futures visualizer} is a graphical profiling tool 
for parallel programs written using @racket[future].  The tool 
shows a timeline of a program's execution including all future-related 
events, as well as the overall amount of processor utilization 
at any point during the program's lifetime. 

@deftogether[(
  @defform[(visualize-futures e ...)]  
  @defproc[(visualize-futures-thunk [thunk (-> any)]) any]
)]{
 The @racket[visualize-futures] macro enables the collection 
 of data required by the visualizer and displays a profiler 
 window showing the corresponding trace.  The @racket[visualize-futures-thunk] 
 provides similar functionality where program code is contained 
 within @racket[thunk].
 
 A typical program using profiling might look like the following: 
 
 @racketblock[
    (require racket/future 
             racket/future/visualizer) 
    
    (visualize-futures 
     (let ([f (future (lambda () ...))]) 
       ... 
       (touch f)))
  ]
 
 The preceding program is equivalent to:
 
 @racketblock[ 
    (require racket/future 
             racket/future/trace
             racket/future/visualizer) 
                                      
    (start-performance-tracking!) 
    (let ([f (future (lambda () ...))]) 
      ... 
      (touch f)) 
    
    (show-visualizer)
 ]
}

@defproc[(show-visualizer) void?]{
 Displays the profiler window.  Calls to this 
 function must be preceded by a call to @racket[start-performance-tracking!] (or can 
 be avoided altogether by using either @racket[visualize-futures] or @racket[visualize-futures-thunk]).
}                                                      

@section[#:tag "future-visualizer-timeline"]{Execution Timeline} 

The @deftech{execution timeline}, shown in the top left-hand corner of the 
profiler window, displays a history of the program 
and all events associated with its futures, with OS-level threads 
or @deftech{processes} organized along the y-axis and time increasing along 
the x-axis.  A coloring convention is used to distinguish between 
different types of events (see @secref["future-logging"] for a full 
description of these event types): 

@itemlist[ 
  @item{Blue dot: @racket['create]} 
   
  @item{Green bar: @racket['start-work], @racket['start-0-work]} 
  
  @item{Orange dot: @racket['sync]} 
  
  @item{Red dot: @racket['block], @racket['touch]} 
  
  @item{White dot: @racket['result], @racket['end-work]} 
  
  @item{Green dot: @racket['touch-pause], @racket['touch-resume]}  
]

Mousing over any event connects it via purple lines to the sequence 
of events for its future.  Additionally, orange dotted lines 
with arrowheads may be shown to indicate operations performed from 
one future to another (e.g. @racket['create] or @racket['touch] actions).  
To view details about two events simultaneously, a selection 
can be tacked by clicking the mouse.  

The timeline displays vertical lines at 100-microsecond intervals.  Note that 
though the time interval is fixed, the pixel distance between lines varies 
based on the event density for any given time range to prevent overlapping 
event circles.  

@defproc[(timeline-pict [events (listof indexed-future-event?)] 
                        [#:x x (or #f exact-nonnegative-integer?) #f] 
                        [#:y y (or #f exact-nonnegative-integer?) #f] 
                        [#:width width (or #f exact-nonnegative-integer?) #f] 
                        [#:height height (or #f exact-nonnegative-integer?) #f] 
                        [#:selected-event-index selected-event-index (or #f exact-nonnegative-integer?) #f]) pict?]{
  Returns a @racket[pict] showing the execution timeline for the trace in @racket[events].  The optional 
  arguments @racket[x], @racket[y], @racket[width], and @racket[height] can be used to obtain a specific 
  area (in pixels) of the timeline image.  The @racket[selected-event-index] argument, if specified, shows 
  the timeline image as if the user placed the mouse pointer over the @racket[indexed-future-event] with 
  the corresponding index.
}                                                                                                      

@section[#:tag "future-visualizer-tree"]{Future Creation Tree} 

The @deftech{creation tree} shows a tree with a single node per 
future created by the program.  This display can be particularly useful 
for programs which spawn futures in nested fashion (futures within futures).  
For any given future node, the children 
of that node represent futures which were created by that future (within 
the scope of its thunk).  For all programs, the root of the tree 
is a special node representing the main computation thread (the runtime thread), 
and is denoted @deftech{RTT}.

@defproc[(creation-tree-pict [events (listof indexed-future-event?)] 
                              [#:x x (or #f exact-nonnegative-integer?) #f] 
                              [#:y y (or #f exact-nonnegative-integer?) #f] 
                              [#:width width (or #f exact-nonnegative-integer?) #f] 
                              [#:node-width node-width (or #f exact-nonnegative-integer?) #f]
                              [#:height height (or #f exact-nonnegative-integer?) #f] 
                              [#:padding padding (or #f exact-nonnegative-integer?) #f] 
                              [#:zoom zoom exact-nonnegative-integer? 1]) pict?]{
  Returns a @racket[pict] showing the future creation tree for the trace in @racket[events].  The optional 
  arguments @racket[x], @racket[y], @racket[width], and @racket[height] can be used to obtain a specific 
  area (in pixels) of the creation tree image.  The @racket[node-width] argument 
  specifies (in pixels) the diameter of each node.  The @racket[padding] argument specifies the minimum space vertically 
  between each depth and horizontally between siblings.  The @racket[zoom] argument specifies the zoom factor for the 
  tree image in the range 1-5, where 5 returns a 500% zoom.
}