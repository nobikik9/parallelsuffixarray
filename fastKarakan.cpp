#include <bits/stdc++.h>
#include <ctime>
using namespace std;

#define REP(i, n) for (int i = 0; i < (n); ++i)
#define FWD(i, l, r) for (int i = (l); i < (r); ++i)
#define BCK(i, r, l) for (int i = (r); i > (l); --i)

// biblioteczka UJ
const int MAXN = 50000005;
int _count[MAXN];
void countSort(int* in, int* out, const int* key, int N, int M){
  fill_n(_count, M, 0);
  REP(i,N)++_count[key[in[i]]];
  FWD(i,1,M)_count[i] += _count[i-1];
  BCK(i,N-1,-1)out[--_count[key[in[i]]]] = in[i];
}

int temp[MAXN], s0[MAXN], s12[MAXN],_rank[MAXN], recOut[MAXN];
const int* _s;
inline bool cmp(int u, int v){
  while(true){
    if(_s[u] != _s[v]) return _s[u]<_s[v];
    if((u%3) && (v%3)) return _rank[u] < _rank[v];
    ++u;++v;
  }
}

/*IN: N - dlugosc
  IN: s - string   
  IN: K - zakres alfabetu
  OUT: out - tablica sufiksowa
 !!ZALOZENIA: N>=2, 0<s[i]<K, s[N]=s[N+1]=s[N+2]=0!! */
void suffixArray(const int* s, int N, int* out, int K){
  int n0 = (N+2)/3, n1 = (N+1)/3, n12 = 0; 
  REP(i,N)if(i%3)temp[n12++] = i;

  countSort(temp, s12, s+2, n12, K);
  countSort(s12, temp, s+1, n12, K);
  countSort(temp, s12, s,   n12, K);    

  int recIn[n12+5], cnt = 2;  
  REP(i,n12){
    if(i>0 && !equal(s+s12[i-1], s+s12[i-1]+3, s+s12[i]))++cnt;
    recIn[s12[i]%3==1?s12[i]/3:s12[i]/3+n1+1] = cnt;  
  }  
  
  if(cnt != n12+1){
    REP(i,3) recIn[n12+1+i] = 0;  
    recIn[n1] = 1;    
    suffixArray(recIn, n12+1, recOut, cnt+1);
    FWD(i,1,n12+1)s12[i-1] = recOut[i]<n1? 3*recOut[i]+1 : 3*(recOut[i]-n1)-1;
  }  
  
  REP(i,n12)_rank[s12[i]] = i+1;  
  _rank[N] = 0;

  REP(i,n0)s0[i] = 3*i;
  countSort(s0,temp,_rank+1,n0,n12+2);   
  countSort(temp,s0,s,n0,K);  

  _s = s;
  merge(s12, s12+n12, s0, s0+n0, out, cmp);  
}

/*IN: sA - tablica sufiksowa
  IN: invSA - odwrotnosc tablicy sufiksowej
  IN: N - dlugosc
  IN: text - string; T[N]!=T[i] dla i<N!!
  OUT: lcp */ 
void computeLCP(const int* sA, const int* invSA, int N, int* text, int* lcp){
  int cur = 0;
  REP(i,N){
    int j = invSA[i];
    if(!j)continue;
    int k = sA[j-1];
    while(text[k+cur] == text[i+cur])cur++;
    lcp[j] = cur;
    cur = max(0,cur-1);
  }
}

int s[MAXN];
int t[MAXN];

int main(int argc, char* argv[]) {
    srand(42);
    int n = stoi(argv[1]);
    REP(i, n) s[i] = '0' + rand() % 2;
    auto start = std::clock();
    suffixArray(s, n, t, 128);
    auto end = std::clock();
    std::cout << "Time (Karkkainen): " << (double)(end-start)/CLOCKS_PER_SEC << std::endl;
    return 0;
}