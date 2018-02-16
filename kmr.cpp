#include <bits/stdc++.h>
using namespace std;

const int len = 50000005;
int n, arr[len], cur[len], cn[len], cnt[len], p[len], pn[len],cls;

void buildSA() {
    arr[n] = 0; ++n;
    for (int i = 0; i < n; ++i) cnt[arr[i]]++;
    for (int i = 1; i < 256; ++i) cnt[i] += cnt[i - 1];
    for (int i = 0; i < n; ++i) p[--cnt[arr[i]]] = i;
    cur[p[0]] = 0; cls = 1;
    for (int i = 1; i < n; ++i) {
        if (arr[p[i]] != arr[p[i - 1]]) ++cls;
        cur[p[i]] = cls - 1;
    }
    for (int h = 0; (1 << h) < n; ++h) {
        for (int i = 0; i < n; ++i) {
            pn[i] = p[i] - (1 << h);
            if (pn[i] < 0) pn[i] += n;
        }
        for (int i = 0; i < cls; ++i) cnt[i] = 0;
        for (int i = 0; i < n; ++i) ++cnt[cur[pn[i]]];
        for (int i = 1; i < cls; ++i) cnt[i] += cnt[i - 1];
        for (int i = n - 1; i >= 0; --i) p[--cnt[cur[pn[i]]]] = pn[i];
        cn[p[0]] = 0; cls = 1;
        for (int i = 1; i < n; ++i) {
            int sd1 = (p[i] + (1 << h)) % n;
            int sd2 = (p[i - 1] + (1 << h)) % n;
            if (cur[p[i]] != cur[p[i - 1]] || cur[sd1] != cur[sd2]) ++cls;
            cn[p[i]] = cls - 1;
        }
        for (int i = 0; i < n; ++i) cur[i] = cn[i];
    }
}

char s[len];

int main(int argc, char* argv[]) {
    srand(42);

    n = stoi(argv[1]);

    for (int i = 0; i < n; ++i) {
        arr[i] = '0' + rand() % 2;
    }

    auto start = std::clock();
    buildSA();
    auto end = std::clock();
    std::cout << "Time (KMR): " << (double)(end-start)/CLOCKS_PER_SEC << std::endl;
    return 0;
}