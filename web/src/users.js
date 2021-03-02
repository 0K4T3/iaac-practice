export default {
  list: async function () {
    const response = await this._callApi('GET');
    return response['users']
  },
  add: async function (userId) {
    const response = await this._callApi('POST', userId)
    return response['users'];
  },
  delete: async function (userId) {
    const response = await this._callApi('DELETE', userId);
    return response['users'];
  },
  _callApi: async function (method, userId = '') {
    console.log(process.env);
    let url = `${process.env.REACT_APP_API_ENDPOINT}/users`;
    if (userId.length > 0) {
      url += `/${userId}`;
    }
    const response = await fetch(url, {
      method: method,
    });
    const responseJson = await response.json();
    return responseJson;
  },
};
