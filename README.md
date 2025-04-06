### Openledger

#### 获取 token

```
javascript

function getCookieValue(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
}

const token = getCookieValue('opw_base_user_token');
console.log(token);
```