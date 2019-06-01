/* [sh, cw_valid, iter] = ldpc_decode_spa_mex(H, LLRin, sumX1, sumX2, i_idx-1, j_idx-1, max_iter)
 *
 * Matlab MEX acceleration for ldpc_decode_spa function.
 *
 * Copyright 2019 Grzegorz Cisek (grzegorzcisek@gmail.com)
 */

#include "mex.h"
#include "matrix.h"
#include <math.h>

#define VMAX_MAX 200

#define MAX(x,y) ((x < y) ? ( y) : (  x))
#define MIN(x,y) ((x > y) ? ( y) : (  x))
#define ABS(x)   ((x > 0) ? ( x) : (-(x)))
#define SGN(x)   ((x < 0) ? (-1) : (  1))

double ml[VMAX_MAX];
double mr[VMAX_MAX];

int check_syndrome(size_t ncheck, size_t nvar, size_t* H_ir, size_t* H_jc, double* LLR, int* syndrome) {
  size_t v;
  size_t c_idx;
  size_t c;
  int res;

  for (v = 0; v < nvar; v++) {
    for (c_idx = H_jc[v]; c_idx < H_jc[v+1]; c_idx++) {
      c = H_ir[c_idx];
      if (LLR[v] < 0.0) {
        syndrome[c]++; 
      }
    }
  }

  res = 1;
  for (c = 0; c < ncheck; c++) {
    if (syndrome[c] & 1) {
      res = 0;
    }

    syndrome[c] = 0;
  }

  return res;
}

void llr2hardbit(size_t nvar, double* src, double* dest) {
  int n;
  for (n = 0; n < nvar; n++) {
    dest[n] = (src[n] < 0.0) ? 1.0 : 0.0;
  }
}

void fill_mvc(size_t nvar, size_t cmax, double* LLRin, double* mvc) {
  int n;
  int c;  
  for (n = 0; n < nvar; n++) {
    for (c = 0; c < cmax; c++) {
      mvc[n + c*nvar] = LLRin[n];
    }
  }
}

double boxplus(double a, double b) {
  double x1, x2, x3;

  x1 = SGN(a) * SGN(b) * MIN(ABS(a), ABS(b));
  x2 = log(1.0 + exp(-ABS(a+b)));
  x3 = log(1.0 + exp(-ABS(a-b)));
  return x1 + x2 - x3;
}

double boxplus_approx(double a, double b) {
  double x1, x2, x3, r;

  x1 = SGN(a) * SGN(b) * MIN(ABS(a), ABS(b));

  r = ABS(a+b);
  x2 = (r < 2.5) ? (0.6 - 0.24 * r) : 0.0;

  r = ABS(a-b);
  x3 = (r < 2.5) ? (0.6 - 0.24 * r) : 0.0;

  return x1 + x2 - x3;
}

void ldpc_decode_spa(size_t ncheck, size_t nvar, size_t cmax, size_t vmax, size_t* H_ir, size_t* H_jc, double* LLRin, double* sumX1, double* sumX2, double* i_idx, double* j_idx, int max_iters, double* out, double* cw_valid, double* iter) {
  int i, j, n;
  int* syndrome;
  double* mcv;
  double* mvc;

  syndrome = mxMalloc(sizeof(int) * ncheck);
  mcv = mxMalloc(sizeof(double) * ncheck * vmax);
  mvc = mxMalloc(sizeof(double) * nvar * cmax);

  for (i = 0; i < ncheck; i++) syndrome[i] = 0;
  for (i = 0; i < ncheck * vmax; i++) mcv[i] = 0.0;
  fill_mvc(nvar, cmax, LLRin, mvc);

  if (check_syndrome(ncheck, nvar, H_ir, H_jc, LLRin, syndrome)) {
    llr2hardbit(nvar, LLRin, out);
    *cw_valid = 1;
    *iter = 0;
    return;
  }

  *cw_valid = 0;

  for ((*iter) = 0; (*iter) < max_iters; (*iter)++) {
    for (j = 0; j < ncheck; j++) {
      n = sumX2[j] - 1;

      ml[0] = mvc[(int)j_idx[j]];
      mr[0] =  mvc[(int)j_idx[j+n*ncheck]];
      for(i = 1; i < n; i++ ) {
        ml[i] = boxplus_approx( ml[i-1], mvc[(int)j_idx[j+i*ncheck]] );
        mr[i] = boxplus_approx( mr[i-1], mvc[(int)j_idx[j+(n-i)*ncheck]] );
      }

      mcv[j] = mr[n-1];
      mcv[j+n*ncheck] = ml[n-1];
      for(i = 1; i < n; i++ )
        mcv[j+i*ncheck] = boxplus_approx( ml[i-1], mr[n-1-i] );
    }

    for (i = 0; i < nvar; i++) {
      out[i] = LLRin[i];
      for (j = 0; j < (int)sumX1[i]; j++) {
        out[i] += mcv[(int)i_idx[i + j*nvar]];
      }
      for (j = 0; j < (int)sumX1[i]; j++) {
        mvc[i + j*nvar] = out[i] - mcv[(int)i_idx[i + j*nvar]];
      }
    }

    if (check_syndrome(ncheck, nvar, H_ir, H_jc, out, syndrome)) {
      *cw_valid = 1;
      break;
    }
  }

  llr2hardbit(nvar, out, out);

  mxFree(syndrome);
  mxFree(mcv);
  mxFree(mvc);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  size_t ncheck, nvar, cmax, vmax;
  size_t* H_ir;
  size_t* H_jc;
  double* LLRin;
  double* sumX1;
  double* sumX2;
  double* i_idx;
  double* j_idx;

  double* sh;
  double* cw_valid;
  double* iter;

  int max_iters;

  /* check for proper number and format of arguments */
  if(nrhs != 7)
    mexErrMsgIdAndTxt("ldpc_decode_spa:nrhs","Seven inputs required.");

  if(nlhs > 3)
    mexErrMsgIdAndTxt("ldpc_decode_spa:nlhs","At most three outputs required.");

  /* get the input arguments */
  ncheck = mxGetM(prhs[0]);
  nvar   = mxGetN(prhs[0]);
  cmax   = mxGetN(prhs[4]);
  vmax   = mxGetN(prhs[5]);

  H_ir = mxGetIr(prhs[0]);
  H_jc = mxGetJc(prhs[0]);

  LLRin = mxGetPr(prhs[1]);
  sumX1 = mxGetPr(prhs[2]);
  sumX2 = mxGetPr(prhs[3]);
  i_idx = mxGetPr(prhs[4]);
  j_idx = mxGetPr(prhs[5]);
  
  max_iters = (int)mxGetScalar(prhs[6]);

  /* create the output matrix */
  plhs[0] = mxCreateDoubleMatrix((mwSize)nvar, 1, mxREAL);
  sh = mxGetPr(plhs[0]);

  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
  cw_valid = mxGetPr(plhs[1]);

  plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
  iter = mxGetPr(plhs[2]);

  /* call the computational routine */
  ldpc_decode_spa(ncheck, nvar, cmax, vmax, H_ir, H_jc, LLRin, sumX1, sumX2, i_idx, j_idx, max_iters, sh, cw_valid, iter);
}