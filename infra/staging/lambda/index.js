const { ECSClient, ListTasksCommand, DescribeTasksCommand, StopTaskCommand, UpdateServiceCommand } = require("@aws-sdk/client-ecs");

const ecs = new ECSClient();

exports.handler = async (event, context) => {
    try {
        const clusterName = 'wca-registration-staging';

        const listTasksParams = {
            cluster: clusterName,
            desiredStatus: 'RUNNING'
        };

        const listTasksCommand = new ListTasksCommand(listTasksParams);
        const tasks = await ecs.send(listTasksCommand);

        for (const taskArn of tasks.taskArns) {
            const describeTaskParams = {
                cluster: clusterName,
                tasks: [taskArn]
            };

            const describeTaskCommand = new DescribeTasksCommand(describeTaskParams);
            const taskDetails = await ecs.send(describeTaskCommand);
            const task = taskDetails.tasks[0];

            if (isTaskOlderThanOneHour(task)) {
                const stopTaskParams = {
                    cluster: clusterName,
                    task: taskArn
                };

                const stopTaskCommand = new StopTaskCommand(stopTaskParams);
                await ecs.send(stopTaskCommand);
                console.log(`Terminated task: ${taskArn}`);

                const updateServiceParams = {
                    cluster: clusterName,
                    service: "Staging-Service",
                    desiredCount: 0
                };

                const updateServiceCommand = new UpdateServiceCommand(updateServiceParams);
                await ecs.send(updateServiceCommand);
                console.log(`Updated service: ${task.serviceArn} to set desired task count to 0`);
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
