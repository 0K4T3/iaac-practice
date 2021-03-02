import { useEffect, useState } from 'react';
import Users from './users';
import './App.css';

function App() {
  const [users, setUsers] = useState([]);
  const [userIdInputValue, setUserIdInputValue] = useState('');

  const handleOnChangeUserId = (event) => {
    setUserIdInputValue(event.currentTarget.value);
  };
  const handleClickAdd = async () => {
    const users = await Users.add(userIdInputValue);
    setUsers(users);
    setUserIdInputValue('');
  };
  const handleClickDelete = async () => {
    const users = await Users.delete(userIdInputValue);
    setUsers(users);
    setUserIdInputValue('');
  };
  useEffect(() => {
    (async () => {
      const users = await Users.list();
      setUsers(users);
    })();
  }, []);

  return (
    <div className="App">
      {(users || []).map(user => (
        <div>{user.UserId}</div>
      ))}
      <input type="text" value={userIdInputValue} onChange={handleOnChangeUserId} />
      <button type="button" onClick={handleClickAdd}>ADD</button>
      <button type="button" onClick={handleClickDelete}>DELETE</button>
    </div>
  );
}

export default App;
