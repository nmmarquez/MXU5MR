#include <TMB.hpp>
#include <Eigen/Sparse>
#include <vector>
using namespace density;
using Eigen::SparseMatrix;


template<class Type>
SparseMatrix<Type> iid_Q(int N){
    SparseMatrix<Type> Q(N, N);
    for(int i = 0; i < N; i++){
        Q.insert(i,i) = 1.;
    }
    return Q;
}

template<class Type>
SparseMatrix<Type> lcar_Q(SparseMatrix<Type> Wstar, Type rho, Type sigma){
    int N = Wstar.rows();
    
    SparseMatrix<Type> I(N, N);
    for(int i = 0; i < N; i++){
        I.insert(i,i) = 1.;
    }
    
    SparseMatrix<Type> Q = (1. / sigma) * (rho * (Wstar) + (1. - rho) * I);
    return Q;
}

template<class Type>
SparseMatrix<Type> ar_Q(int N, Type rho, Type sigma) {
    SparseMatrix<Type> Q(N,N);
    Q.insert(0,0) = (1.) / pow(sigma, 2.);
    for (size_t n = 1; n < N; n++) {
        Q.insert(n,n) = (1. + pow(rho, 2.)) / pow(sigma, 2.);
        Q.insert(n-1,n) = (-1. * rho) / pow(sigma, 2.);
        Q.insert(n,n-1) = (-1. * rho) / pow(sigma, 2.);
    }
    Q.coeffRef(N-1,N-1) = (1.) / pow(sigma, 2.);
    return Q;
}

template<class Type>
Type objective_function<Type>::operator() (){
    
    DATA_ARRAY(yobs);
    DATA_ARRAY(offset);
    DATA_ARRAY(lik);
    DATA_SPARSE_MATRIX(Wstar); // pre compiled wstar matrix
    DATA_INTEGER(option);
    
    // SPDE objects
    DATA_SPARSE_MATRIX(G0);
    DATA_SPARSE_MATRIX(G1);
    DATA_SPARSE_MATRIX(G2);
    
    printf("%s\n", "Data loaded");
    
    PARAMETER_ARRAY(phi);
    PARAMETER_VECTOR(log_sigma);
    PARAMETER_VECTOR(logit_rho);
    PARAMETER_VECTOR(spparams);
    PARAMETER(beta);
    PARAMETER_VECTOR(beta_age);
    printf("%s\n", "Parameters set.");
    
    printf("%s\n", "Transform parameters.");
    vector<Type> sigma = exp(log_sigma);
    vector<Type> rho = Type(1.) / (Type(1.) + exp(Type(-1.) * logit_rho));
    
    
    int L = yobs.dim(0);        // number of locations
    int A = yobs.dim(1);        // number of ages
    int T = yobs.dim(2);        // number of years
    
    // Initiate log likelihood
    vector<Type> nll(2);
    nll[0] = Type(0);
    nll[1] = Type(0);
    max_parallel_regions = omp_get_max_threads(); 
    
    // Probability of random effects
    printf("%s\n", "Build precision matrix.");
    SparseMatrix<Type> Q_loc;
    Type sprho;
    Type spkappa2;
    Type spkappa4;
    Type Range;
    Type spsigma = exp(spparams[1]);
    
    if(option == 1){
        sprho = Type(1.) / (Type(1.) + exp(Type(-1.) * spparams[0]));
        Q_loc = lcar_Q(Wstar, sprho, spsigma);
    }
    else{
        spkappa2 = exp(2.0*spparams[0]);
        spkappa4 = spkappa2*spkappa2;
        Range = sqrt(8) / exp(spparams[0]);
        Q_loc = spkappa4*G0 + Type(2.0)*spkappa2*G1 + G2;
    }
    SparseMatrix<Type> Q_age = ar_Q(A, rho[0], sigma[0]);
    SparseMatrix<Type> Q_time = ar_Q(T, rho[1], sigma[1]);
    
    printf("%s\n", "Eval RE likelihood.");
    if(option == 1){
        PARALLEL_REGION nll[0] += SEPARABLE(GMRF(Q_time), SEPARABLE(GMRF(Q_age), GMRF(Q_loc)))(phi);
    }
    if(option == 2){
        PARALLEL_REGION nll[0] += SEPARABLE(GMRF(Q_time), SEPARABLE(GMRF(Q_age), SCALE(GMRF(Q_loc), spsigma)))(phi);
    }
    
    printf("%s\n", "Make estimates.");
    // Make predictions
    array<Type> RR(L, A, T);
    for (int l = 0; l < L; l++) {
        for (int a = 0; a < A; a++) {
            for (int t = 0; t < T; t++) {
                if (a != 0){
                    RR(l,a,t) = exp(beta + phi(l,a,t) + beta_age[a-1]);
                }
                else{
                    RR(l,a,t) = exp(beta + phi(l,a,t));
                }
            }
        }
    }
    
    printf("%s\n", "Data likelihood.");
    // Probability of params
    for (int l = 0; l < L; l++) {
        for (int a = 0; a < A; a++) {
            for (int t = 0; t < T; t++) {
                if (offset(l,a,t) != Type(0.) & lik(l,a,t) != Type(0.)){
                    PARALLEL_REGION nll[0] -= dpois(yobs(l,a,t), RR(l,a,t) * offset(l,a,t), true);
                }
                if (offset(l,a,t) != Type(0.) & lik(l,a,t) == Type(0.)){
                    PARALLEL_REGION nll[1] -= dpois(yobs(l,a,t), RR(l,a,t) * offset(l,a,t), true);
                }
            }
        }
    }
    
    printf("%s\n", "Report values.");
    REPORT(sigma);
    REPORT(rho);
    REPORT(beta);
    REPORT(RR);
    REPORT(phi);
    REPORT(Q_loc);
    REPORT(nll);
    REPORT(spsigma);
    REPORT(Range);
    REPORT(sprho);
    
    return nll[0];
}
