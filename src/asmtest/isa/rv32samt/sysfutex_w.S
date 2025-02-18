/*
 * Copyright (c) 2018, Cornell University
 * Copyright (c) 2022, Google LLC
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * Neither the name of Cornell University nor the names of its
 * contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

//------------------------------------------------------------------------
// sysfutex_w tests basic functionalities of futex system call:
//    - make a thread wait on a variable
//    - wake up a thread waiting on a variable
//------------------------------------------------------------------------

#include "riscv_test.h"
#include "test_macros.h"
#include "test_macros_mt_ecall.h"

  RVTEST_RV32U
  RVTEST_CODE_BEGIN

#define NUM_THREADS 1
#define LOOP_COUNT  1000

//------------------------------------------------------------------------
// Master thread creates new threads, call _master function, waits for all
// threads to complete, deallocates threads and checks result
//------------------------------------------------------------------------
  li      a0, NUM_THREADS
  call    _create_threads

  la      t6, n_worker_threads
  lw     a0, (t6)
  beqz    a0, _fail        // exit if there's no worker thread
  call    _master_work

  la      t6, n_worker_threads
  lw      a0, (t6)
  call    _join

  la      t6, n_worker_threads
  lw      a0, (t6)
  call    _check

  la      t6, n_worker_threads
  lw      a0, (t6)
  call    _delete_threads

  li      a0, SUCCESS

  RVTEST_CODE_END

//------------------------------------------------------------------------
// master_work function executed by the parent/master thread
//
//    Wake up thread(s) waiting on futex_X and then wait on futex_Y in a
//    loop.
//------------------------------------------------------------------------
_master_work:
  mv    s0, ra                  // save return address
  li    t0, LOOP_COUNT
  la    t1, count_master

1:
  // futex(futex_X, FUTEX_WAKE_PRIVATE, 1)
  la    a0, futex_X
  li    a1, FUTEX_WAKE_PRIVATE
  li    a2, 1                   // wake up at most 1 thread
  li    a7, SYSCALL_FUTEX
  ecall

  // keep waking up until at least one thread is waken up
  beqz  a0, 1b

  // increment count_master
  lw    t2, (t1)
  addi  t2, t2, 1
  sw    t2, (t1)

  // futex(futex_Y, FUTEX_WAIT_PRIVATE, 0)
  la    a0, futex_Y
  li    a1, FUTEX_WAIT_PRIVATE
  li    a2, 0                   // expected val of futex_Y
  li    a7, SYSCALL_FUTEX
  ecall

  // decrement t0
  addi  t0, t0, -1
  bnez  t0, 1b

  // restore return address and return
  mv    ra, s0
  ret

//------------------------------------------------------------------------
// mt_test function executed by child threads
//
//    Wait on futex_X and then wake up threads waiting on futex_Y in a loop
//------------------------------------------------------------------------
_mt_test:
  li    t0, LOOP_COUNT
  la    t1, count_child

1:
  // futex(futex_X, FUTEX_WAIT_PRIVATE, 1)
  la    a0, futex_X
  li    a1, FUTEX_WAIT_PRIVATE
  li    a2, 0                   // expected val of futex_X
  li    a7, SYSCALL_FUTEX
  ecall

  // increment count_child
  lw    t2, (t1)
  addi  t2, t2, 1
  sw    t2, (t1)

2:
  // futex(futex_Y, FUTEX_WAKE_PRIVATE, 0)
  la    a0, futex_Y
  li    a1, FUTEX_WAKE_PRIVATE
  li    a2, 1                   // wake up at most 1 thread
  li    a7, SYSCALL_FUTEX
  ecall

  // keep waking up until at least one thread is waken up
  beqz  a0, 2b

  // decrement t0
  addi  t0, t0, -1
  bnez  t0, 1b

  RVTEST_CODE_END

//------------------------------------------------------------------------
// _check:
//    Each thread should do LOOP_COUNT iterations
//------------------------------------------------------------------------

_check:
  la    t0, count_master
  la    t1, count_child
  li    t2, LOOP_COUNT

  lw    t0, (t0)
  bne   t0, t2, _fail

  lw    t1, (t1)
  bne   t1, t2, _fail

  ret

_fail:
  li        a0, FAILURE
  RVTEST_CODE_END

  .data

futex_X:  .word  0
futex_Y:  .word  0

count_master:   .word  0
count_child:    .word  0

MT_DATA
