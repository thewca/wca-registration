const AWS = require('aws-sdk');
const ecs = new AWS.ECS();

exports.handler = async (event, context) => {
    try {
        const clusterName = 'wca-registration-staging';

        const listTasksParams = {
            cluster: clusterName,
            desiredStatus: 'RUNNING'
        };

        const tasks = await ecs.listTasks(listTasksParams).promise();

        for (const taskArn of tasks.taskArns) {
            const describeTaskParams = {
                cluster: clusterName,
                tasks: [taskArn]
            };

            const taskDetails = await ecs.describeTasks(describeTaskParams).promise();
            const task = taskDetails.tasks[0];

            if (isTaskOlderThanOneHour(task)) {
                const stopTaskParams = {
                    cluster: clusterName,
                    task: taskArn
                };

                await ecs.stopTask(stopTaskParams).promise();
                console.log(`Terminated task: ${taskArn}`);
            }
        }

        return {
            statusCode: 200,
            body: 'Task termination process completed successfully.'
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: 'An error occurred during task termination process.'
        };
    }
};

function isTaskOlderThanOneHour(task) {
    const oneHourInMilliseconds = 60 * 60 * 1000;
    const taskStartTime = task.startedAt.getTime();
    const currentTime = new Date().getTime();
    const elapsedTime = currentTime - taskStartTime;

    return elapsedTime > oneHourInMilliseconds;
}
