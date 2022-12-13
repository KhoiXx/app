import { createStore } from "vuex";
import { auth } from "./auth.module.js";
import { info } from "./info.module.js";
import createPersistedState from 'vuex-persistedstate'

const store = createStore({
	modules: {
		auth,
		info,
	},
	plugins: [createPersistedState()]
});
export default store;