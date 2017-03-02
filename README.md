# A Bauman BeRo TinyPascal

A ported version of self-hosting capable [BeRo Tiny Pascal Compiler](https://github.com/BeRo1985/berotinypascal) for the Linux x64 platform

## Original license

     ******************************************************************************
     *                                zlib license                                *
     *============================================================================*
     *                                                                            *
     * Copyright (C) 2006-2016, Benjamin Rosseaux (benjamin@rosseaux.com)         *
     *                                                                            *
     * This software is provided 'as-is', without any express or implied          *
     * warranty. In no event will the authors be held liable for any damages      *
     * arising from the use of this software.                                     *
     *                                                                            *
     * Permission is granted to anyone to use this software for any purpose,      *
     * including commercial applications, and to alter it and redistribute it     *
     * freely, subject to the following restrictions:                             *
     *                                                                            *
     * 1. The origin of this software must not be misrepresented; you must not    *
     *    claim that you wrote the original software. If you use this software    *
     *    in a product, an acknowledgement in the product documentation would be  *
     *    appreciated but is not required.                                        *
     * 2. Altered source versions must be plainly marked as such, and must not be *
     *    misrepresented as being the original software.                          *
     * 3. This notice may not be removed or altered from any source distribution. *
     *                                                                            *
     ******************************************************************************

## How-to-use

### Basic compiler usage

     btpc64 < myProgram.pas > myProgram

### Runtime reassemble

     gcc -c rtl64.s
     ld rtl64.o -g -o rtl64 -T linkerScript.ld -nostdlib
     
## Porting notes

Provided ported version is a part of compilers course project at [BMSTU ICS-9](https://github.com/bmstu-iu9) in 2017. 

Porting author - Anthony Belyaev.

Original BTPC author - Benjamin Rosseaux.

### Source code annotations

Ported version of BTPC was provided with annotations to some functions/procs of original compiler:

    {=}   - nothing was changed
    {-}   - original function is not used in new version
    {ab}  - function's insides was chagned or minorly fixed
    {?}   - need to think a little
    {!}   - mistake in original code / commentary
    {new} - newly created func/proc/variable

RTL64 was also provided with some self-tests and debugging macroses
