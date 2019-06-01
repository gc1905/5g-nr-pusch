/* d = nr_38_212_circbuff_deinterleave_mex(f, N, Q_m, k_0, Fbst, Fbsz)
 *
 * Matlab MEX acceleration for nr_38_212_rate_unmatching_ldpc function.
 *
 * Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */

#include <stdlib.h>
#include "mex.h"

void circbuff_deinterleave(double* bits_f, size_t bits_f_len, double* bits_d, size_t bits_d_len, int Q_m, int k_0, int Fbst, int Fbsz) {
  double* bits_e;
  int i, j, EdQm, k_ptr;

  bits_e = mxMalloc(bits_f_len * sizeof(double));

  EdQm = (int) (bits_f_len / Q_m);

  for (i = 0; i < EdQm; i++)
    for (j = 0; j < Q_m; j++)
      bits_e[j*EdQm+i] = bits_f[j+i*Q_m];

  i = k_0;
  j = 0;

  for (i = 0; i < bits_f_len; i++) {
    k_ptr = (k_0 + i) % bits_d_len;
    if (k_ptr == Fbst) {
      i += Fbsz - 1;
    } else {
      bits_d[k_ptr] += bits_e[j];
      j++;
    }
  }

  mxFree(bits_e);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double* bits_f;
  size_t bits_f_len;
  double* bits_d;
  size_t bits_d_len;
  int Q_m, k_0, Fbst, Fbsz;

  /* check for proper number of arguments */
  if(nrhs != 6) {
    mexErrMsgIdAndTxt("nr_38_212_circbuff_interleave:nrhs","Six inputs required.");
  }

  if(nlhs != 1) {
    mexErrMsgIdAndTxt("nr_38_212_circbuff_interleave:nlhs","One output required.");
  }

  /* get the input arguments */
  bits_f_len = mxGetM(prhs[0]) * mxGetN(prhs[0]);
  bits_f = mxGetPr(prhs[0]);
  bits_d_len = (int) mxGetScalar(prhs[1]);
  Q_m = (int) mxGetScalar(prhs[2]);
  k_0 = (int) mxGetScalar(prhs[3]);
  Fbst = (int) mxGetScalar(prhs[4]);
  Fbsz = (int) mxGetScalar(prhs[5]);

  /* create the output matrix */
  plhs[0] = mxCreateDoubleMatrix(1, (mwSize)bits_d_len, mxREAL);

  /* get a pointer to the real data in the output matrix */
  bits_d = mxGetPr(plhs[0]);

  /* call the computational routine */
  circbuff_deinterleave(bits_f, bits_f_len, bits_d, bits_d_len, Q_m, k_0, Fbst, Fbsz);
}
