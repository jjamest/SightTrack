# SightTrackV2

### Changes from V1
- Use Amplify SDK for backend (so no need for making custom APIS)
- Redesign UI
- Minimal features
- Location offset
- Better user management
- Group management (User, Admin) - No admin panel yet
- Google maps -> Mapbox Flutter
- Better data management via Amplify Studio
- Easier data analysis
- Profile picture, country, bio, email, username (display_username)

### Unchanged
- Photo recognition still uses AWS Rekognition
- AWS services

### Photos
##### Data manager in Amplify studio. Can be accessed client-side with @auth(rules: [{allow: private}])

![image](https://github.com/user-attachments/assets/5ad53e23-3f22-4ca5-aa3d-976108b12fc8)


##### Create Sighting

<img width="397" alt="image" src="https://github.com/user-attachments/assets/ddfcd41c-e1ae-444e-adf0-5d09d1dbadd0" />


##### Global map

<img width="393" alt="image" src="https://github.com/user-attachments/assets/b3173738-d164-4194-9d25-a3e609cfe395" />
