import React from 'react';
import RegistrationPanel from "./register/components/registration_panel";
import styles from "./index.module.scss"
import RegistrationList from "./register/components/registration_list";



export default function App() {
    return <div className={styles.container}>
        <RegistrationPanel> </RegistrationPanel>
        <RegistrationList></RegistrationList>
    </div>
}
