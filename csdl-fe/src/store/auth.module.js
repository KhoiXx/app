export const auth = {
    namespaced: true,
    state: {
        user: null,
        token: null,
        loggedIn: false,
        permission: 0,
    },
    actions: {
        login({ commit }, info) {
            if(info['status']){
                commit("loginSuccess", info);
                return Promise.resolve(info['username']);
            } else {
                return Promise.reject(info['username']);
            }
        },
        logout({ commit }) {
            commit("logout");
        },
        // register({ commit }, user) {
        //   return AuthService.register(user).then(
        //     response => {
        //       commit('registerSuccess');
        //       return Promise.resolve(response.data);
        //     },
        //     error => {
        //       commit('registerFailure');
        //       return Promise.reject(error);
        //     }
        //   );
        // }
    },
    mutations: {
        loginSuccess(state, info) {
            state.loggedIn = true;
            state.user = info['username'];
            state.token = info['token'];
            state.permission = info['permission'];
        },
        logout(state) {
            state.loggedIn = false;
            state.user = null;
            state.token = null;
        },
        // registerSuccess(state) {
        //   state.status.loggedIn = false;
        // },
        // registerFailure(state) {
        //   state.status.loggedIn = false;
        // }
    },
};
