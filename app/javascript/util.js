import { v4 as uuidv4 } from 'uuid';
import text from 'texts/lesson5';


export const getChunk = () => {
    const lines = text.split('\n');
    const randomIndex = Math.floor(Math.random() * lines.length);
    let chunk = lines[randomIndex];
    let tokens = chunk.length;

    let earlier = randomIndex;
    let later = randomIndex

    while ((tokens / 4) < 1600) {
        if (earlier > 0 && (Math.random() > 0.5 || later >= lines.length - 1)) {
            earlier -= 1;
            chunk = lines[earlier] + ' ' + chunk;
            tokens += lines[earlier].length;
        } else if (later < lines.length - 1) {
            later += 1;
            chunk = chunk + ' ' + lines[later];
            tokens += lines[later].length;
        } else {
            break;
        }
    }

    return chunk;
}

export const getUserId = () => {
    let id = localStorage.getItem('userId');

    if (!id) {
        localStorage.setItem('userId', uuidv4());
        id = localStorage.getItem('userId');
    }

    return id;
};