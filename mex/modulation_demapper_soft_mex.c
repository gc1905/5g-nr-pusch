/* x = modulation_demapper_soft_mex(iq, ord, method, N0, A, S0-1, S1-1)
 *
 * Matlab MEX acceleration for modulation_demapper_soft function.
 *
 * Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */

#include "mex.h"
#include <string.h>
#include <math.h>

#define POW2(X) ((X)*(X))

void demapprt_true_llr(double* iq_re, double* iq_im, size_t iq_size, int ord, double* N0, double* A_re, double* A_im, double* S0, double* S1, double* llr) {
  int i, q, a, s_idx;
  double P0, P1, P0_metric, P1_metric;
  int alphabet_size = (1<<ord);

  for (i = 0; i < iq_size; i++) {
    for (q = 0; q < ord; q++) {
      P0 = 0.0;
      P1 = 0.0;
      for (a = 0; a < alphabet_size / 2; a++) {
        s_idx = q + a*ord;
        P0_metric = POW2(iq_re[i] - A_re[(int)S0[s_idx]]) + POW2(iq_im[i] - A_im[(int)S0[s_idx]]);
        P1_metric = POW2(iq_re[i] - A_re[(int)S1[s_idx]]) + POW2(iq_im[i] - A_im[(int)S1[s_idx]]);
        P0 += exp(-1.0 * P0_metric / N0[i]);
        P1 += exp(-1.0 * P1_metric / N0[i]);
      }
      llr[(i+1)*ord-q-1] = log(P0) - log(P1);
    }
  }
}

void demapprt_approx_llr(double* iq_re, double* iq_im, size_t iq_size, int ord, double* N0, double* A_re, double* A_im, double* S0, double* S1, double* llr) {
  int i, q, a, s_idx;
  double d0, d1, v;
  int alphabet_size = (1<<ord);

  for (i = 0; i < iq_size; i++) {
    for (q = 0; q < ord; q++) {
      d0 = 9999999.0;
      d1 = 9999999.0;
      for (a = 0; a < alphabet_size / 2; a++) {
        s_idx = q + a*ord;
        v = POW2(iq_re[i] - A_re[(int)S0[s_idx]]) + POW2(iq_im[i] - A_im[(int)S0[s_idx]]);
        d0 = d0 < v ? d0 : v;
        v = POW2(iq_re[i] - A_re[(int)S1[s_idx]]) + POW2(iq_im[i] - A_im[(int)S1[s_idx]]);
        d1 = d1 < v ? d1 : v;
      }
      llr[(i+1)*ord-q-1] = -1.0 * (d0 - d1) / N0[i];
    }
  }
}

void demapprt_hard(double* iq_re, double* iq_im, size_t iq_size, int ord, double* N0, double* A_re, double* A_im, double* S0, double* S1, double* llr) {
  int i, q, a, s_idx;
  double d0, d1, v;
  int alphabet_size = (1<<ord);

  for (i = 0; i < iq_size; i++) {
    for (q = 0; q < ord; q++) {
      d0 = 9999999.0;
      d1 = 9999999.0;
      for (a = 0; a < alphabet_size / 2; a++) {
        s_idx = q + a*ord;
        v = POW2(iq_re[i] - A_re[(int)S0[s_idx]]) + POW2(iq_im[i] - A_im[(int)S0[s_idx]]);
        d0 = d0 < v ? d0 : v;
        v = POW2(iq_re[i] - A_re[(int)S1[s_idx]]) + POW2(iq_im[i] - A_im[(int)S1[s_idx]]);
        d1 = d1 < v ? d1 : v;
      }
      llr[(i+1)*ord-q-1] = (d0 > d1) ? (-1.0 / N0[i]) : (1.0 / N0[i]);
    }
  }
}

void modulation_demapper_soft(double* iq_re, double* iq_im, size_t iq_size, int ord, char* method, double* N0, double* A_re, double* A_im, double* S0, double* S1, double* llr) {
  if (strcmp(method,"True LLR") == 0)
    demapprt_true_llr(iq_re, iq_im, iq_size, ord, N0, A_re, A_im, S0, S1, llr);
  else if (strcmp(method,"Approx LLR") == 0)
    demapprt_approx_llr(iq_re, iq_im, iq_size, ord, N0, A_re, A_im, S0, S1, llr);
  else if (strcmp(method,"Hard") == 0)
    demapprt_hard(iq_re, iq_im, iq_size, ord, N0, A_re, A_im, S0, S1, llr);
  else
    mexErrMsgIdAndTxt("modulation_demapper_soft:method","Invalid demodulation method");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double* iq_re;
  double* iq_im;
  size_t iq_size;
  int ord;
  char* method;
  double* N0;
  size_t N0_size;

  double* A_re;
  double* A_im;
  double* S0;
  double* S1;

  size_t llr_size;
  double* llr;

  /* check for proper number of arguments */
  if(nrhs != 7) {
    mexErrMsgIdAndTxt("modulation_demapper_soft:nrhs","Seven inputs required.");
  }

  if(nlhs != 1) {
    mexErrMsgIdAndTxt("modulation_demapper_soft:nlhs","One output required.");
  }

  /* get the input arguments */
  iq_size = mxGetM(prhs[0]) * mxGetN(prhs[0]);
  iq_re = mxGetPr(prhs[0]);
  iq_im = mxGetPi(prhs[0]);

  ord = (int) mxGetScalar(prhs[1]);

  method = mxArrayToString(prhs[2]);

  N0 = mxGetPr(prhs[3]);

  A_re = mxGetPr(prhs[4]);
  A_im = mxGetPi(prhs[4]);

  S0 = mxGetPr(prhs[5]);
  S1 = mxGetPr(prhs[6]);

  /* create the output matrix */
  llr_size = iq_size * ord;
  plhs[0] = mxCreateDoubleMatrix((mwSize)llr_size, 1, mxREAL);

  /* get a pointer to the real data in the output matrix */
  llr = mxGetPr(plhs[0]);

  /* call the computational routine */
  modulation_demapper_soft(iq_re, iq_im, iq_size, ord, method, N0, A_re, A_im, S0, S1, llr);
}