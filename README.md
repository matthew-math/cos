# Convex Optimization Suite

Getting Started
===============

The directory structure is intended to be reasonably intuitive. To get started, the user simply executes the run\_me.m file in MATLAB. While adding this project directory to your path may be required initially, all subfolders, e.g. functions, algos, custom, etc., are coded to be accessible without any further configuration needed on the user's part. User is immediately presented with an option menu similar to:

Enter the number of your menu choice:

1. Run full test suite

2. Use specific test function

3. Read more about test functions 

4. Use custom function

Enter menu choice \[Default: 1\]: 

Note that simply pressing the enter / return key has the same effect as typing the number 1, followed by enter / return. Throughout this interface, a default option (if applicable) is normally indicated using this square bracket notation, i.e. \[Default \<option\>\].

Run full test suite
-------------------

From here the full bank of test objective functions (those stored in the *functions* project subdirectory) will be evaluated in automated fashion. However, you may choose to evaluate the objective functions using one specific minimization algorithm or all algorithms (those stored in the *algos* project subdirectory).

Upon selecting to run the full test suite, you will be asked to provide a starting point, $x_{0}$. You may hit enter to use the default option. Note that you may enter the starting position as a vector by separating entries with semicolons, e.g. \[0.5; 0.5\], but if you simply enter a string of the starting coordinates, e.g. \[0.5, 0.5\] or 0.5 0.5 0.5, the software will transform this to a suitable column-format vector.

Use specific test function
--------------------------

From here you may choose to evaluate a specific test objective functions (from those stored in the *functions* project subdirectory). You may also choose to evaluate the objective function using one specific minimization algorithm or all algorithms (stored in the *algos* project subdirectory).

This focused option may be useful if you know that a particular objective function is particularly problematic. Also, if you change the $\mathbb{R}^{n}$ space to something other than 2 (by modifying the RnSpace global in the run\_me.m file), the Rosenbrock function is currently the only test function that supports arbitrary dimensions.

Read more about test functions
------------------------------

This opens the website from which test objective functions were obtained in your default web browser. There you may see a detailed explanation of the objective function, expected minimizers, and *much* more. Any supplemental comments in the objective function MATLAB code is drawn from this authoritative resource, so searching through code for a better understanding of what is happening should NOT be necessary.

There are approximately 50 test objective functions on this site. A sampling of these functions are provided with this project (primarily because it gets tedious adding optimized gradient & derivative calculations and these functions are primarily 2 dimensional) to provide a reasonable representation of what is possible with this codebase.

These common objective functions are stored in the functions directory and prefixed with fn\_ in the filename. The filename is used to generate the menu text presented in menus. The objective function function name should match the filename as this is what is used to pass function handles inside the application. You can easily add more objective functions to this directory, by using the existing files as a template and drawing from the objective functions on the referenced website. The general idea is that common objective functions should go inside the *functions* directory and functions that are specific to your work should go inside the *custom* directory.

Use custom function
-------------------

Having a comprehensive suite of example reference functions to play with is certainly nice, but presumabely you have some real minimization work to do. This is where you go to use your own objective functions\... no coding needed (hopefully)! By default, you will be presented with a list of all custom objective functions you've added.

If you would like to create a new objective function, enter 0 (followed by \<enter\>) at the selection menu. The first thing that you will be asked is to enter your objective function, e.g. $f(x)=...$ If you are unsure of the format, look at the example provided at command line for formatting guidelines. If you just hit enter, the simple default objective function will be used. This probably won't be useful, but it allows you to become familiar with the process.

Next, you will name your function (this is used for the filename) and have the opportunity to enter a brief description. This description should focus on the function itself; the date of creation and username are automatically inserted into the file comments. Finally your custom objective function file will be written to disk. This file will contain the objective function you provide, as well as the gradient and Hessian MATLAB computes for you. Do NOT go into the file and remove the Hessian, even if you don't expect to be using optimization algorithms that need it. The suite writes the code in an optimal way so that a gradient and/or Hessian are *only computed if needed*. The custom function you created will now be available for later use and automatically appear under the custom functions menu. You can also examine the newly created file located in the *custom* directory.

Now, whether you just created a new objective function or started with an existing one, you will be asked to select the optimization algorithm and provide a starting point. The objective function will then be evaluated based on your selections.

Extending the suite of reference objective functions
====================================================

The list of reference objective functions is generated dynamically. This means that extending the menu of available objective functions in the test suite is simply a matter of adding additional fn\_\<customfn\>.m files into the functions subdirectory. There are two ways to go about this:

The easy way
------------

If the idea of coding your algorithm in MATLAB doesn't sound appealing, the easiest way to proceed is as follows:

1.  Choose to use a custom function from the main menu, then opt for 0 (create new custom function)

2.  Enter the objective function at the prompt (MATLAB will generate the gradient & Hessian for you)

3.  Choose a filename that corresponds with the common name of the objective function you entered

4.  Make sure there are no problems minimizing the objective function

5.  After program execution, navigate to the custom subdirectory and move this new file to the functions subdirectory

The less easy way
-----------------

If you are not especially worried about writing MATLAB code and/or determining the gradient and Hessian yourself, here is how to proceed:

1.  Make a copy of one of the existing objectiving functions located in the functions subdirectory

2.  Rename the file and function to match one another, keeping in mind MATLAB's function naming restrictions and relevance to the objective function you are coding and that your objective function filename must be prefixed with *fn\_*

3.  Replace the `f = ...` expression with your new reference objective function

4.  Replace `df = ...` with the gradient and `ddf = ...` with the Hessian. Note: by uncommenting the example codeblock, you can have MATLAB compute the gradient and Hessian of your objective function for you during the next run. You will also likely need to manually halt program execution after this information is displayed to console, since the previously coded gradient and Hessian will not match your new objective function.

5.  Save the updated MATLAB code

Extending optimization algorithms
---------------------------------

In addition to providing the flexibility to add an arbitrary number of objective functions, the codebase is intended to be flexible enough to accommodate an arbitrary number of optimization algorithms. A sampling of algorithms for this course, namely Newton's Method, Steepest Descent, SR1, BFGS, and L-BFGS, are already provided and serve as a reference for adding additional algorithms.

If you would like to create your own algorithm, there are a few basic things to keep in mind when getting started. All algorithms are stored in the *algos* directory and named with an "algo\_" prefix. Whatever name you should for your filename, the primary calling function used to execute the algorithm should be named to match, but without algo\_ in the function name. For example, if you were adding a dogleg algorithm, you might call your file algo\_dogleg.m and the corresponding function inside the file would be named:

function \[x,y,k,metrics\] = dogleg(fnHandle, x0, max\_iterations, m, tolerance)

The specific argument names you use aren't critical, but the quantity and order is important. For return variables, x represents x\*, the minimizer, y represents the function value at the minimizer, k represents the number of iterations required to minimize the objective function. The arguments passed to the function are fnHandle, which represents a handle to the function being evaluated, x0 represents the starting point, max\_iterations puts an upper threshold on how many iterations the algorithm will attempt before exiting, m represents a configuration value for your algorithm, and tolerance represents how close your function must be to the minimum before it determines success.

Most of this is self explanatory for the mathematician familiar with optimization. You should note the following elements that may not be intuitive, but are nonetheless vital if your algorithm is going to play nicely with the software. Here is brief description of each of these (refer to the codebase for specific code samples):

> {metrics: this is a struct, which generally consists of the
> following fields}
> *metrics.runtime*: set this to 999 when you first start as a flag that your algorithm is not yet complete. This should ultimately be set to a time that reflects algorithm execution time (refer to code for examples of how to accomplish this with tic & toc). If you do not initially set this to 999, it is likely that you will encounter many errors as you try to complete your code.
>
> metrics.k: represents an array of iterative values (used to complete tabular reports)
>
> metrics.f\_xk: represents an array of values of x at each iteration stored as array
>
> metrics.alpha\_k: represents the step size at each iteration stored as array
>
> You may add additional fields as appropriate for your algorithm and they will be reported in the MATLAB output window
>
> , which then allows you to evaluate any objective function passed to your algorithm like so:

\[f, df, ddf\] = feval(fnHandle, x);

> Note: if you don't need the Hessian (or gradient) leave these variables out of your return array, e.g. \[f, df\] = feval(fnHandle, x). For optimal runtimes, do NOT use the MATLAB \~ convention unless you wish to ignore a leading element, e.g. \[\~, df\] = feval(fnHandle, x) to get the gradient.
>
> : this is the vestige of the early development of this application. It is used for some of the algorithms, but really should be abstracted to a struct in order to support passing arbitrary fields to optimization algorithms. In other words, rather than hard-coding some subjective values, bubbling this choice up to the user interface would be a valuable improvement.

As you grow more familiar with the codebase, you may wish to add a number of algorithms that share a common core. In this case you should save the core inside the *algos* directory without the algo\_ prefix. It will then be accessible to your class of algorithms. Each of your calling algorithms should have a unique name to match their purpose. For a good example of how this works, take a look at the algo\_bfgs.m, algo\_bfgsstrongwolfe.m, algo\_sr1.m, and algo\_sr1strongwolfe.m files that share the QuasiNewton.m file.

Special Considerations
----------------------

The author does not have sufficient experience with MATLAB's flexibility in deriving gradients and Hessians using symbolic notation to make representations regarding its robustness. It is entirely possible that MATLAB may be innaccurate or fail for calculating gradients and/or Hessians for certain kinds of objective functions. In this case, you may need to manually tweak the output from "the easy way." While the author has built the code to theoretically support up to 100 variables, this has not been well tested and may present challenges for entirely non-mathematical reasons, e.g. string length limitations.

Graphical Reporting
=================

Key graphical reporting includes comparative algorithm timing for each objective function, comparitive algorithm iterations for each objective function, and a comparison of how quickly each algorithm converges on a solution. Additionally, higher resolution reports are provided that detail the performance of each algorithm relative to each objective function. Note that the reports vary based on the selected options, primarily to avoid opening 50 windows when running the full test suite.

Future Work
===========

Substantial work has gone into designing a platform that is easily extensible and that could form the basis of a mathematicians optimization workbench; certainly the basis of a student's optimization workbench. The application is designed to be reasonably user friendly and provides enough in-built "demo" functionality that new users should not quickly get bored or frustrated. That being said, there is much potential for further enhancement. Enhancements fall into a few types outlined here.

User testing
------------

This application was built at a frenzied pace and, while the author frequently verified that the various parts were working as expected, it is likely that problems exist that got overlooked or weren't even considered. It is also quite possible, and even likely, that subtle flaws in the code may be readily spotted in the output by an experienced mathematician. This is part of the purpose of providing graphical reports\... to make errors easier to spot.

Additionally, it is likely that compromises the author deemed reasonable are overly restrictive in actual real-world use. Decisions regarding maximum iterations, for example, may be unreasonable for serious problems. It is also possible that some user interface choices can be further streamlined.

Enhancements
------------

Options abound when it comes to enhancements. Currently, constrained optimization problems are not considered and the interface is likely deficient in being able to collect user-defined constraints. For this reason, contrained optimization algorithms would be a good next step to extend the application.

Providing a way to encode known solutions for test objective functions would provide a means for automated testing and validation of algorithms. It could also be used to insure the integrity of the sotware between updates. The challenge is standardizing a reasonably intuitive solution that will not unnecessarily burden those who wish to add objective functions to the test suite.

Put more work into supporting test objective functions in spaces bigger than $\mathbb{R}{}^{2}$. Currently the only objective function that supports arbitrary dimensions is the Rosenbrock function and specifying that n \> 2 requires modifying a global variable in the run\_me.m file. Perhaps, in the course of enhancing the objective function file to support known solutions, support could be included for specifying the intended $\mathbb{R}{}^{n}$space(s). This would be useful in more comprehensive validation of algorithms and simulating more realistic use cases.

Implement support for algorithms and scenarios that involve datasets rather than carefully defined functions. The author is not yet familiar with such minimization scenarios, but a comprehensive optimization platform should include support for analyzing datasets and/or "black box functions" for which even gradient data may not be readily available.

Testing custom user-defined functions for convexity. This was planned, based largely on code in MathWorks File Exchange that represented to do this very thing. In trying to use this code, however, it became clear that it did not function as represented and does not appear to ever have been intended to evaluate objective functions for which the Hessian contains constants (or zeros). This is a worthwhile enhancement for improving the user experience, but has a very narrow usefulness overall, so creating alternative code took a backseat to higher priorities with the application. This should be revisited at some point.

No software enhancement list would be complete without mentioning code clean-up and abstraction. There are currently several line search and step length methods that are similar in function, but associated with different optimization algorithms that could likely be consolidated. It is also likely that deprecated variables remain from when a particular algorithm was built as a stand-alone script.

Bug fixes
---------

The author is not aware of any specific bugs or functionality that does not work as intended, but this is likely the result of insufficient testing.

Disclaimers
===========

This software has not been tested by anyone other than the author and should not be relied on for any purpose. Although most of the code is original and the author's creation with assistance from course references, instructor guidance, course textbook, and the below citations, it is also possible that incompatible source code licenses have been mixed in using outside source code (e.g. reference objective functions or code included from MathWorks File Exchange). Where code is not the author's, sources are cited in the source code. While the author is concientious of software licensing, it is possible that something, even specific to MATLAB itself, has been overlooked. In the event you notice a conflict, the author welcomes your feedback. All code was created in fulfillment of academic course requirements and may not yet be suitable for general use.

1 Jorge Nocedal, Stephen J. Wright. 2006. Numerical Optimization 2nd Ed. Springer.

Virtual Library of Simulation Experiments: Test Functions and Datasets. [https://www.sfu.ca/$\sim$ssurjano/optimization.html](https://www.sfu.ca/~ssurjano/optimization.html).

MATLAB Documentation. <https://www.mathworks.com/help/matlab/index.html>.

MATLAB Answers. <https://www.mathworks.com/matlabcentral/answers/>.

MathWorks File Exchange. <https://www.mathworks.com/matlabcentral/fileexchange/>.
