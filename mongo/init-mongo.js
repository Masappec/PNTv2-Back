db.createUser(
    {
        user: 'root',
        pwd: 'rootpassword',
        roles: [
            {
                role: 'readWrite',
                db: 'public_api_service'
            }
        ]
    }
)